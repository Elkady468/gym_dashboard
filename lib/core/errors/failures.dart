import 'package:equatable/equatable.dart';

// ── Domain-layer failures ─────────────────────────────────────────────────────
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  @override
  List<Object> get props => [message];
}

class ServerFailure  extends Failure { const ServerFailure(super.m, {this.statusCode}); final int? statusCode; @override List<Object> get props => [message, statusCode ?? 0]; }
class NetworkFailure extends Failure { const NetworkFailure() : super('No internet connection'); }
class AuthFailure    extends Failure { const AuthFailure(super.m); }
class CacheFailure   extends Failure { const CacheFailure(super.m); }
class UnknownFailure extends Failure { const UnknownFailure() : super('An unexpected error occurred'); }
