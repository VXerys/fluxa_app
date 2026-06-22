class VoiceTransactionEntity {
  final String type;
  final double amount;
  final String category;
  final String? wallet;
  final String? title;
  final String? description;
  final String currency;
  final String? date;

  const VoiceTransactionEntity({
    required this.type,
    required this.amount,
    required this.category,
    this.wallet,
    this.title,
    this.description,
    required this.currency,
    this.date,
  });
}
