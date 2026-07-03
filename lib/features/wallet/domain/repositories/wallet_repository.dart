import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/wallet_entity.dart';

class CreateWalletParams {
  final String name;
  final String type;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;

  CreateWalletParams({
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
  });
}

class UpdateWalletParams {
  final String id;
  final String? name;
  final String? icon;
  final String? color;
  final bool? includeInTotal;
  final int? sortOrder;
  final double? balance;

  UpdateWalletParams({
    required this.id,
    this.name,
    this.icon,
    this.color,
    this.includeInTotal,
    this.sortOrder,
    this.balance,
  });
}

abstract class WalletRepository {
  Future<Either<Failure, List<WalletEntity>>> getWallets();
  Future<Either<Failure, WalletEntity>> getWalletById(String id);
  Future<Either<Failure, WalletEntity>> createWallet(CreateWalletParams params);
  Future<Either<Failure, WalletEntity>> updateWallet(UpdateWalletParams params);
  Future<Either<Failure, void>> archiveWallet(String id);
  Future<Either<Failure, double>> getTotalBalance();
}
