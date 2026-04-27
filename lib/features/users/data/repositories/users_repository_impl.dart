import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_datasource.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource _remote;
  UsersRepositoryImpl(this._remote);

  T _wrap<T>(T Function() fn) {
    try {
      return fn();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException {
      throw const NetworkFailure();
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({String? search}) async {
    try {
      return Right(await _remote.getUsers(search: search));
    } on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException { return const Left(NetworkFailure()); }
    catch (_) { return const Left(UnknownFailure()); }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(int id) async {
    try { return Right(await _remote.getUserById(id)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    catch (_) { return const Left(UnknownFailure()); }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(int id, Map<String, dynamic> data) async {
    try { return Right(await _remote.updateUser(id, data)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    catch (_) { return const Left(UnknownFailure()); }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try { await _remote.deleteUser(id); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    catch (_) { return const Left(UnknownFailure()); }
  }
}
