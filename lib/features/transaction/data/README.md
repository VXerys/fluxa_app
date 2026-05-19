transaction/data — Data layer for transactions

Purpose:
- Provide a local datasource (sqflite or simple JSON) for storing transactions.
- Provide `TransactionModel` for persistence and mapping to `TransactionEntity`.

Planned files:
- `datasources/transaction_local_datasource.dart`
- `datasources/transaction_local_datasource_impl.dart`
- `models/transaction_model.dart`
- `repositories/transaction_repository_impl.dart` (maps Exceptions -> Failures)