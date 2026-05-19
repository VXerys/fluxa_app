import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getSystemCategories();
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByType(
    String type,
  );
}
