import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/users_repository.dart';

class GetUsersUseCase {
  final UsersRepository _r;
  GetUsersUseCase(this._r);
  Future<Either<Failure, List<UserEntity>>> call({String? search}) =>
      _r.getUsers(search: search);
}

class GetUserByIdUseCase {
  final UsersRepository _r;
  GetUserByIdUseCase(this._r);
  Future<Either<Failure, UserEntity>> call(int id) => _r.getUserById(id);
}

class UpdateUserUseCase {
  final UsersRepository _r;
  UpdateUserUseCase(this._r);
  Future<Either<Failure, UserEntity>> call(int id, Map<String, dynamic> data) =>
      _r.updateUser(id, data);
}

class DeleteUserUseCase {
  final UsersRepository _r;
  DeleteUserUseCase(this._r);
  Future<Either<Failure, void>> call(int id) => _r.deleteUser(id);
}
