presentation/controllers — TransactionController

Responsibilities:
- Expose `addTransaction()` calling `AddTransactionUseCase`.
- Manage `RxList<TransactionEntity>` for list display.
- Expose loading and error states using Rx.

Validation rules:
- `amount` required and > 0
- `category` required
- `date` default today