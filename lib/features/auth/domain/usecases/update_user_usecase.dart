import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateUserUseCase implements UseCase<UserEntity, UpdateUserParams> {
  final AuthRepository repository;

  UpdateUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateUserParams params) async {
    return await repository.updateUser(displayName: params.displayName);
  }
}

class UpdateUserParams {
  final String displayName;

  UpdateUserParams({required this.displayName});
}
