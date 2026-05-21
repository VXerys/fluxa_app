import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetAllSystemCategoriesUseCase
    implements UseCase<List<CategoryEntity>, NoParams> {
  final CategoryRepository repository;

  GetAllSystemCategoriesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) {
    return repository.getAllSystemCategories();
  }
}
