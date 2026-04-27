import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/users_usecases.dart';

abstract class UsersState extends Equatable {
  const UsersState();
  @override List<Object?> get props => [];
}
class UsersInitial extends UsersState {}
class UsersLoading extends UsersState {}
class UsersLoaded extends UsersState {
  final List<UserEntity> users;
  final String query;
  const UsersLoaded({required this.users, this.query = ''});
  @override List<Object> get props => [users, query];
}
class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
  @override List<Object> get props => [message];
}
class UserActionSuccess extends UsersState {
  final String message;
  const UserActionSuccess(this.message);
  @override List<Object> get props => [message];
}

class UsersCubit extends Cubit<UsersState> {
  final GetUsersUseCase    _getUsers;
  final UpdateUserUseCase  _updateUser;
  final DeleteUserUseCase  _deleteUser;

  UsersCubit(this._getUsers, this._updateUser, this._deleteUser)
      : super(UsersInitial());

  Future<void> loadUsers({String? search}) async {
    emit(UsersLoading());
    final result = await _getUsers(search: search);
    result.fold(
      (f) => emit(UsersError(f.message)),
      (users) => emit(UsersLoaded(users: users, query: search ?? '')),
    );
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final result = await _updateUser(id, data);
    result.fold(
      (f) => emit(UsersError(f.message)),
      (_) {
        emit(const UserActionSuccess('User updated successfully'));
        loadUsers();
      },
    );
  }

  Future<void> deleteUser(int id) async {
    final result = await _deleteUser(id);
    result.fold(
      (f) => emit(UsersError(f.message)),
      (_) {
        emit(const UserActionSuccess('User deleted'));
        loadUsers();
      },
    );
  }
}
