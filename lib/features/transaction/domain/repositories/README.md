domain/repositories — TransactionRepository contract

Example:
```dart
abstract class TransactionRepository {
  Future<Either<Failure, Unit>> addTransaction(TransactionEntity t);
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
}
```

Repository is an interface; implementation belongs to `data/repositories`.