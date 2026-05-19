domain/usecases — Home usecases

- `GetHomeSummaryUseCase` should call `GetTransactionsUseCase` and compute totals.
- Keep aggregation logic in domain/usecase, not in UI.