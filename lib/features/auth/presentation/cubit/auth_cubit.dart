import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/usecases/auth_usecases.dart';

// ── States ────────────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}
class AuthInitial        extends AuthState {}
class AuthLoading        extends AuthState {}
class AuthAuthenticated  extends AuthState {
  final AdminUserEntity user;
  const AuthAuthenticated(this.user);
  @override List<Object> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError          extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase  _login;
  final GetMeUseCase  _getMe;
  final LogoutUseCase _logout;
  final dynamic       _storage; // TokenStorage

  AuthCubit(this._login, this._getMe, this._logout, this._storage)
      : super(AuthInitial());

  /// On app start — validate stored token
  Future<void> checkAuth() async {
    if (!(_storage.hasTokens as bool)) {
      emit(AuthUnauthenticated());
      return;
    }
    emit(AuthLoading());
    final result = await _getMe();
    result.fold(
      (_) {
        _storage.clearTokens();
        emit(AuthUnauthenticated());
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> login({required String username, required String password}) async {
    emit(AuthLoading());
    final tokenResult = await _login(username: username, password: password);
    await tokenResult.fold(
      (f) async => emit(AuthError(f.message)),
      (_) async {
        final meResult = await _getMe();
        meResult.fold(
          (f) => emit(AuthError(f.message)),
          (user) => emit(AuthAuthenticated(user)),
        );
      },
    );
  }

  Future<void> logout() async {
    await _logout();
    emit(AuthUnauthenticated());
  }

  AdminUserEntity? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;
}
