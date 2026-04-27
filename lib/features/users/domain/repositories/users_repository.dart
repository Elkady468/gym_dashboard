import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers({String? search});
  Future<Either<Failure, UserEntity>> getUserById(int id);
  Future<Either<Failure, UserEntity>> updateUser(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteUser(int id);
}
