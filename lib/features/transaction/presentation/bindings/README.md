presentation/bindings — TransactionBinding

Purpose:
- Lazy register TransactionLocalDataSource, TransactionRepositoryImpl, usecases, and TransactionController.

Ensure order: datasource -> repository -> usecase -> controller.
Attach this binding to transaction routes.