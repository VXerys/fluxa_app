import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

class ArchiveWalletParams {
  final String walletId;

  const ArchiveWalletParams({required this.walletId});
}

class ArchiveWalletUseCase implements UseCase<void, ArchiveWalletParams> {
  final WalletRepository repository;

  ArchiveWalletUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ArchiveWalletParams params) async {
    return repository.archiveWallet(params.walletId);
  }
}
