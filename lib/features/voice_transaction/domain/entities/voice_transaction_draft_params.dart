class VoiceTransactionDraftParams {
  final String title;
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
    required this.title,
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

  String? get displayTitle => _normalizedOrNull(title);

  String get effectiveCurrency {
    final String trimmed = currency.trim();
    return trimmed.isEmpty ? 'IDR' : trimmed;
  }

  String? get resolvedTransactionCategoryId => categoryId ?? subcategoryId;

  String? get displayCategory => _normalizedOrNull(categoryName);

  String? get displayWallet => _normalizedOrNull(walletName);

  String? get displayDescription => _normalizedOrNull(description);

  bool get hasMeaningfulTitle {
    final String? normalizedTitle = displayTitle;
    if (normalizedTitle == null) return false;
    return normalizedTitle.toLowerCase() != 'transaksi suara';
  }

  String? get combinedNote {
    final String? normalizedTitle = displayTitle;
    final String? normalizedDescription = displayDescription;

    if (normalizedTitle == null && normalizedDescription == null) {
      return null;
    }
    if (normalizedDescription == null || normalizedDescription == normalizedTitle) {
      return normalizedTitle;
    }
    if (normalizedTitle == null) {
      return normalizedDescription;
    }
    return '$normalizedTitle - $normalizedDescription';
  }

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
