class VoiceTransactionDraftParams {
  final String? type;
  final double? amount;
  final String? categoryName;
  final String? categoryId;
  final String? subcategoryName;
  final String? subcategoryId;
  final String? walletName;
  final String? walletId;
  final String? description;
  final String currency;
  final String transcriptRaw;
  final String transcriptNormalized;
  final DateTime occurredAt;

  const VoiceTransactionDraftParams({
    required this.type,
    required this.amount,
    required this.categoryName,
    required this.categoryId,
    required this.subcategoryName,
    required this.subcategoryId,
    required this.walletName,
    required this.walletId,
    required this.description,
    required this.currency,
    required this.transcriptRaw,
    required this.transcriptNormalized,
    required this.occurredAt,
  });

  String get effectiveCurrency {
    final String trimmed = currency.trim();
    return trimmed.isEmpty ? 'IDR' : trimmed;
  }

  String? get resolvedTransactionCategoryId => subcategoryId ?? categoryId;

  String? get displayCategory {
    final String? parent = _normalizedOrNull(categoryName);
    final String? child = _normalizedOrNull(subcategoryName);

    if (parent == null && child == null) return null;
    if (parent == null) return child;
    if (child == null) return parent;
    return '$parent • $child';
  }

  String? get displayWallet => _normalizedOrNull(walletName);

  String? get displayDescription => _normalizedOrNull(description);

  String? get timeString {
    final String hour = occurredAt.hour.toString().padLeft(2, '0');
    final String minute = occurredAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  static String? _normalizedOrNull(String? value) {
    if (value == null) return null;
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
