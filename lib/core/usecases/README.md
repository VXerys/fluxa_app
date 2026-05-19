core/usecases — Base UseCase classes

Purpose:
- Provide an abstract `UseCase<Type, Params>` base.
- Provide `NoParams` class for parameterless usecases.

Guidelines:
- Use `Either<Failure, T>` as return types.
- Keep usecase logic in domain layer of features.