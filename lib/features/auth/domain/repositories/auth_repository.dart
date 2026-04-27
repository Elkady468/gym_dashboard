import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entities.dart';

abstract class AuthRepository {
  Future<Either<Failure, TokenEntity>> login({
    required String username,
    required String password,
  });
  Future<Either<Failure, AdminUserEntity>> getMe();
  Future<Either<Failure, void>> logout();
}
