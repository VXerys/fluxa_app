import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<WalletEntity>>> getWallets() async {
    try {
      final models = await remoteDataSource.getWallets();
      return Right(models.map((model) => model.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> getWalletById(String id) async {
    try {
      final model = await remoteDataSource.getWalletById(id);
      return Right(model.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> createWallet(
    CreateWalletParams params,
  ) async {
    try {
      final model = WalletModel(
        id: '',
        userId: '',
        name: params.name,
        type: params.type,
        balance: params.balance,
        currency: params.currency,
        icon: params.icon,
        color: params.color,
        isArchived: false,
        includeInTotal: true,
        sortOrder: 0,
      );
      final result = await remoteDataSource.createWallet(model);
      return Right(result.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> updateWallet(
    UpdateWalletParams params,
  ) async {
    try {
      final current = await remoteDataSource.getWalletById(params.id);

      final model = WalletModel(
        id: current.id,
        userId: current.userId,
        name: params.name ?? current.name,
        type: current.type,
        balance: params.balance ?? current.balance,
        currency: current.currency,
        icon: params.icon ?? current.icon,
        color: params.color ?? current.color,
        isArchived: current.isArchived,
        includeInTotal: params.includeInTotal ?? current.includeInTotal,
        sortOrder: params.sortOrder ?? current.sortOrder,
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      );

      final result = await remoteDataSource.updateWallet(model);
      return Right(result.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> archiveWallet(String id) async {
    try {
      await remoteDataSource.archiveWallet(id);
      return const Right<Failure, void>(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalBalance() async {
    try {
      final models = await remoteDataSource.getWallets();
      double total = 0;
      for (final wallet in models) {
        if (wallet.includeInTotal) {
          total += wallet.balance;
        }
      }
      return Right(total);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
