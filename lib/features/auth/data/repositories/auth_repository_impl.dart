import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/token_storage.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _storage;
  AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, TokenEntity>> login(
      {required String username, required String password}) async {
    try {
      final token = await _remote.login(username: username, password: password);
      await _storage.saveTokens(access: token.access, refresh: token.refresh);
      return Right(token);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> getMe() async {
    try {
      return Right(await _remote.getMe());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refresh = _storage.getRefreshToken();
      if (refresh.isNotEmpty) await _remote.logout(refreshToken: refresh);
    } catch (_) {
      // always clear tokens even if API fails
    }
    await _storage.clearTokens();
    return const Right(null);
  }
}
