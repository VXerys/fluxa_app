import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class CreateWalletUseCase
    implements UseCase<WalletEntity, CreateWalletParams> {
  final WalletRepository repository;

  CreateWalletUseCase({required this.repository});

  static const Set<String> _validTypes = <String>{
    'cash',
    'bank',
    'ewallet',
    'credit',
    'savings',
    'investment',
  };

  @override
  Future<Either<Failure, WalletEntity>> call(CreateWalletParams params) async {
    if (params.name.trim().isEmpty) {
      return const Left(ServerFailure('Wallet name cannot be empty'));
    }
    if (!_validTypes.contains(params.type)) {
      return const Left(ServerFailure('Invalid wallet type'));
    }
    return repository.createWallet(params);
  }
}
