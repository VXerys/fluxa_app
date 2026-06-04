class AmountParser {
  const AmountParser();

  static final RegExp _numericAmountPattern = RegExp(
    r'(?:rp\s*)?(\d+(?:[.,]\d+)*)\s*(rb|ribu|rebu|k|juta|jt)?',
    caseSensitive: false,
  );

  static const Map<String, int> _numberWords = <String, int>{
    'nol': 0,
    'hiji': 1,
    'satu': 1,
    'dua': 2,
    'tilu': 3,
    'tiga': 3,
    'opat': 4,
    'empat': 4,
    'lima': 5,
    'genep': 6,
    'enam': 6,
    'tujuh': 7,
    'dalapan': 8,
    'delapan': 8,
    'salapan': 9,
    'sembilan': 9,
    'sapuluh': 10,
    'sepuluh': 10,
    'sawelas': 11,
    'sebelas': 11,
  };

  static const Set<String> _amountTokens = <String>{
    'nol',
    'hiji',
    'satu',
    'dua',
    'tilu',
    'tiga',
    'opat',
    'empat',
    'lima',
    'genep',
    'enam',
    'tujuh',
    'dalapan',
    'delapan',
    'salapan',
    'sembilan',
    'sapuluh',
    'sepuluh',
    'sawelas',
    'sebelas',
    'belas',
    'puluh',
    'ratus',
    'saratus',
    'seratus',
    'ribu',
    'rebu',
    'juta',
    'sarebu',
    'seribu',
  };

  double? parse(String input) {
    final normalized = _normalizeText(input);
    final numericAmount = _parseNumericAmount(normalized);
    if (numericAmount != null) {
      return numericAmount;
    }

    return _parseWordAmount(normalized);
  }

  String _normalizeText(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  double? _parseNumericAmount(String input) {
    for (final match in _numericAmountPattern.allMatches(input)) {
      final rawNumber = match.group(1);
      if (rawNumber == null) continue;

      final parsedNumber = _parseLocalizedNumber(rawNumber);
      if (parsedNumber == null) continue;

      final suffix = match.group(2)?.toLowerCase();
      return parsedNumber * _suffixMultiplier(suffix);
    }

    return null;
  }

  double? _parseLocalizedNumber(String rawNumber) {
    final value = rawNumber.trim();
    if (value.isEmpty) return null;

    final hasDot = value.contains('.');
    final hasComma = value.contains(',');

    if (hasDot && hasComma) {
      final lastDot = value.lastIndexOf('.');
      final lastComma = value.lastIndexOf(',');
      if (lastComma > lastDot) {
        return double.tryParse(value.replaceAll('.', '').replaceAll(',', '.'));
      }

      return double.tryParse(value.replaceAll(',', ''));
    }

    if (hasDot || hasComma) {
      final parts = value.split(RegExp(r'[.,]'));
      final isThousands = parts.length > 1 &&
          parts.skip(1).every((part) => part.length == 3);

      if (isThousands) {
        return double.tryParse(parts.join());
      }

      return double.tryParse(value.replaceAll(',', '.'));
    }

    return double.tryParse(value);
  }

  double _suffixMultiplier(String? suffix) {
    switch (suffix) {
      case 'rb':
      case 'ribu':
      case 'rebu':
      case 'k':
        return 1000;
      case 'juta':
      case 'jt':
        return 1000000;
      default:
        return 1;
    }
  }

  double? _parseWordAmount(String input) {
    final tokens = input
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty)
        .toList();

    double? bestAmount;
    var bestLength = 0;
    var index = 0;

    while (index < tokens.length) {
      if (!_amountTokens.contains(tokens[index])) {
        index++;
        continue;
      }

      final segment = <String>[];
      var cursor = index;
      while (cursor < tokens.length && _amountTokens.contains(tokens[cursor])) {
        segment.add(tokens[cursor]);
        cursor++;
      }

      final amount = _parseAmountSegment(segment);
      if (amount != null && segment.length > bestLength) {
        bestAmount = amount;
        bestLength = segment.length;
      }

      index = cursor;
    }

    return bestAmount;
  }

  double? _parseAmountSegment(List<String> tokens) {
    if (tokens.isEmpty) return null;

    var total = 0.0;
    var current = 0.0;
    var hasValue = false;
    var index = 0;

    while (index < tokens.length) {
      final token = tokens[index];

      if (token == 'sarebu' || token == 'seribu') {
        total += 1000;
        hasValue = true;
        index++;
        continue;
      }

      if (token == 'saratus' || token == 'seratus') {
        current += 100;
        hasValue = true;
        index++;
        continue;
      }

      if (token == 'ribu' || token == 'rebu') {
        total += (current == 0 ? 1 : current) * 1000;
        current = 0;
        hasValue = true;
        index++;
        continue;
      }

      if (token == 'juta') {
        total += (current == 0 ? 1 : current) * 1000000;
        current = 0;
        hasValue = true;
        index++;
        continue;
      }

      final number = _numberWords[token];
      if (number == null) {
        index++;
        continue;
      }

      final nextToken = index + 1 < tokens.length ? tokens[index + 1] : null;
      if (nextToken == 'belas') {
        current += number + 10;
        index += 2;
      } else if (nextToken == 'puluh') {
        current += number * 10;
        index += 2;
      } else if (nextToken == 'ratus') {
        current += number * 100;
        index += 2;
      } else {
        current += number;
        index++;
      }

      hasValue = true;
    }

    if (!hasValue) return null;
    return total + current;
  }
}
