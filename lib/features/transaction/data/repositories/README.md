data/repositories — TransactionRepository implementation

Purpose:
- Implement `TransactionRepository` contract from domain.
- Call datasource, map model -> entity, and map exceptions to `Failure`.

Return types must be `Future<Either<Failure, T>>`.