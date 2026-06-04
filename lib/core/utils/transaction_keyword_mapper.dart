class TransactionKeywordMapper {
  const TransactionKeywordMapper();

  static const String income = 'income';
  static const String expense = 'expense';
  static const String transfer = 'transfer';

  static const List<String> _transferKeywords = <String>[
    'transfer',
    'mindahkeun',
    'kirim',
    'top up',
  ];

  static const List<String> _incomeKeywords = <String>[
    'asup',
    'nampi',
    'narima',
    'meunang',
    'dibayar',
    'bayaran',
    'gajih',
    'bonus',
  ];

  static const List<String> _expenseKeywords = <String>[
    'bayar',
    'beli',
    'jajan',
    'belanja',
    'balanja',
    'keluar',
    'kapake',
    'habis',
    'ngeusian',
  ];

  String? detectType(String normalizedText) {
    final text = normalizedText.trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );

    if (_containsAnyKeyword(text, _transferKeywords)) {
      return transfer;
    }
    if (_containsAnyKeyword(text, _incomeKeywords)) {
      return income;
    }
    if (_containsAnyKeyword(text, _expenseKeywords)) {
      return expense;
    }

    return null;
  }

  bool _containsAnyKeyword(String input, List<String> keywords) {
    return keywords.any((keyword) => _containsToken(input, keyword));
  }

  bool _containsToken(String input, String token) {
    final escapedToken = RegExp.escape(token);
    final pattern = RegExp(
      '(^|[^A-Za-z0-9_])$escapedToken(?=\$|[^A-Za-z0-9_])',
      caseSensitive: false,
    );

    return pattern.hasMatch(input);
  }
}
