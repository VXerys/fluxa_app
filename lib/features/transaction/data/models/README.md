data/models — TransactionModel

Guidelines:
- Model should extend `TransactionEntity`.
- Provide `fromJson`, `toJson`, and `toEntity()`.

Fields example:
- id, type, amount, category, note, date

Keep JSON keys stable for DB compatibility.