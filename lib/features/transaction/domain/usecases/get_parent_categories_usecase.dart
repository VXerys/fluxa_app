import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetParentCategoriesParams {
  final String type;

  const GetParentCategoriesParams({required this.type});
}

class GetParentCategoriesUseCase
    implements UseCase<List<CategoryEntity>, GetParentCategoriesParams> {
  final CategoryRepository repository;

  GetParentCategoriesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(
    GetParentCategoriesParams params,
  ) async {
    if (params.type != 'income' && params.type != 'expense') {
      return const Left(ServerFailure('Invalid category type'));
    }
    return repository.getParentCategoriesByType(params.type);
  }
}
