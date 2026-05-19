transaction/presentation — Presentation layer (GetX)

Purpose:
- Pages: AddTransactionPage, TransactionListPage
- Controllers: TransactionController (manages add/get)
- Bindings: register datasources, repository impl, usecases, controller
- Widgets: transaction item, form fields

Guidelines:
- Controller only calls usecases; no direct datasource calls.
- Use private Rx state + public getters.