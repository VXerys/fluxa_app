class VoiceTransactionEntity {
  final String type;
  final double amount;
  final String category;
  final String? wallet;
  final String? description;
  final String currency;

  const VoiceTransactionEntity({
    required this.type,
    required this.amount,
    required this.category,
    this.wallet,
    this.description,
    required this.currency,
  });
}
