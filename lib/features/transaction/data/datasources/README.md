data/datasources — Transaction datasource

Files:
- `transaction_local_datasource.dart` (interface)
- `transaction_local_datasource_impl.dart` (sqflite implementation)

Responsibilities:
- insertTransaction(TransactionModel)
- getTransactions()
- deleteTransaction(id)

Notes:
- For prototype, a simple local JSON file may be used, but sqflite is recommended.