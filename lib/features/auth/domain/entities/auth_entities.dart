import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  const AdminUserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role = 'admin',
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object> get props => [id, username, email, role];
}

class TokenEntity extends Equatable {
  final String access;
  final String refresh;
  const TokenEntity({required this.access, required this.refresh});
  @override
  List<Object> get props => [access, refresh];
}
