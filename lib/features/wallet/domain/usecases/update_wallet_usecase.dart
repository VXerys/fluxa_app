import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class UpdateWalletUseCase
    implements UseCase<WalletEntity, UpdateWalletParams> {
  final WalletRepository repository;

  UpdateWalletUseCase({required this.repository});

  @override
  Future<Either<Failure, WalletEntity>> call(UpdateWalletParams params) async {
    return repository.updateWallet(params);
  }
}
