import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoryTreeParams {
  final String type;

  const GetCategoryTreeParams({required this.type});
}

class GetCategoryTreeUseCase
    implements UseCase<List<CategoryEntity>, GetCategoryTreeParams> {
  final CategoryRepository repository;

  GetCategoryTreeUseCase({required this.repository});

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(
    GetCategoryTreeParams params,
  ) async {
    if (params.type != 'income' && params.type != 'expense') {
      return const Left(ServerFailure('Invalid category type'));
    }
    return repository.getCategoryTreeByType(params.type);
  }
}
