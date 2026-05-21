import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/wallet_repository.dart';

class GetTotalBalanceUseCase implements UseCase<double, NoParams> {
  final WalletRepository repository;

  GetTotalBalanceUseCase({required this.repository});

  @override
  Future<Either<Failure, double>> call(NoParams params) async {
    return repository.getTotalBalance();
  }
}
