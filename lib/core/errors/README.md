core/errors — Exceptions and Failures

Purpose:
- Define `exceptions.dart` for datasource/network throwables.
- Define `failures.dart` for domain-level errors used in `Either<Failure, T>`.

Guidelines:
- Datasources throw Exceptions.
- Repositories map Exceptions -> Failures.
- Use `dartz` Either for usecase returns.