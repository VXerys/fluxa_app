import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesParams {
  final String? type;

  const GetCategoriesParams({this.type});
}

class GetCategoriesUseCase
    implements UseCase<List<CategoryEntity>, GetCategoriesParams> {
  final CategoryRepository repository;

  GetCategoriesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(
    GetCategoriesParams params,
  ) async {
    final type = params.type;
    if (type == null || type.isEmpty) {
      return repository.getSystemCategories();
    }
    if (!_isValidType(type)) {
      return Left(ServerFailure('Invalid category type'));
    }
    return repository.getCategoriesByType(type);
  }

  bool _isValidType(String type) => type == 'income' || type == 'expense';
}
