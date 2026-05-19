home/domain — Domain for Home feature

Suggested usecase:
- `GetHomeSummaryUseCase` — aggregates totals and picks recent transactions.

Return type: `Either<Failure, HomeSummaryEntity>` (HomeSummaryEntity includes totals and recent list).