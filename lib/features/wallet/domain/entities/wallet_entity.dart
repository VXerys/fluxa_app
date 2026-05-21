class WalletEntity {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;
  final bool isArchived;
  final bool includeInTotal;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WalletEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
    required this.isArchived,
    required this.includeInTotal,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });
}
