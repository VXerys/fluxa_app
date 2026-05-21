import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletsUseCase implements UseCase<List<WalletEntity>, NoParams> {
  final WalletRepository repository;

  GetWalletsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<WalletEntity>>> call(NoParams params) async {
    return repository.getWallets();
  }
}
