transaction/domain — Domain layer for transactions

Contents:
- `entities/` — `TransactionEntity` (pure model)
- `repositories/` — `TransactionRepository` contract
- `usecases/` — `AddTransactionUseCase`, `GetTransactionsUseCase`

Guidelines:
- No references to data or presentation in domain.
- Use `Either<Failure, T>` for usecase returns.