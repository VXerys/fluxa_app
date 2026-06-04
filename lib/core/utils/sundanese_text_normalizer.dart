class SundaneseTextNormalizer {
  const SundaneseTextNormalizer();

  static const Map<String, String> _phraseReplacements = <String, String>{
    'sangu goréng': 'nasi goreng',
    'sangu goreng': 'nasi goreng',
    'ojék online': 'ojek online',
    'ojek online': 'ojek online',
  };

  static const Map<String, String> _wordReplacements = <String, String>{
    'mésér': 'beli',
    'meser': 'beli',
    'meuli': 'beli',
    'mli': 'beli',
    'mayar': 'bayar',
    'myr': 'bayar',
    'rébu': 'ribu',
    'rebu': 'ribu',
    'duit': 'uang',
    'ojol': 'ojek online',
  };

  static const Map<String, String> _walletReplacements = <String, String>{
    'bca': 'BCA',
    'bri': 'BRI',
    'mandiri': 'Mandiri',
    'gopay': 'GoPay',
    'dana': 'Dana',
    'ovo': 'OVO',
    'shopeepay': 'ShopeePay',
    'cash': 'Cash',
  };

  String normalize(String input) {
    var normalized = _normalizeSpaces(input.trim().toLowerCase());

    for (final entry in _phraseReplacements.entries) {
      normalized = _replaceToken(normalized, entry.key, entry.value);
    }

    for (final entry in _wordReplacements.entries) {
      normalized = _replaceToken(normalized, entry.key, entry.value);
    }

    normalized = _normalizeSpaces(normalized);

    for (final entry in _walletReplacements.entries) {
      normalized = _replaceToken(normalized, entry.key, entry.value);
    }

    return _normalizeSpaces(normalized);
  }

  String _normalizeSpaces(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _replaceToken(String input, String token, String replacement) {
    final escapedToken = RegExp.escape(token);
    final pattern = RegExp(
      '(^|[^A-Za-z0-9_])($escapedToken)(?=\$|[^A-Za-z0-9_])',
      caseSensitive: false,
    );

    return input.replaceAllMapped(pattern, (match) {
      return '${match.group(1) ?? ''}$replacement';
    });
  }
}
