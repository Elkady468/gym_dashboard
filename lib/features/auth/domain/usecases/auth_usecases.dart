import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _r;
  LoginUseCase(this._r);
  Future<Either<Failure, TokenEntity>> call(
          {required String username, required String password}) =>
      _r.login(username: username, password: password);
}

class GetMeUseCase {
  final AuthRepository _r;
  GetMeUseCase(this._r);
  Future<Either<Failure, AdminUserEntity>> call() => _r.getMe();
}

class LogoutUseCase {
  final AuthRepository _r;
  LogoutUseCase(this._r);
  Future<Either<Failure, void>> call() => _r.logout();
}
