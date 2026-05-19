presentation/controllers — HomeController

Responsibilities:
- call `GetHomeSummaryUseCase`
- expose `RxInt totalIncome`, `RxInt totalExpense`, `RxInt balance`
- expose `RxList<TransactionEntity> recentTransactions`