import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final bool isActive;
  final DateTime? dateJoined;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.role = 'member',
    this.isActive = true,
    this.dateJoined,
  });

  String get fullName => '$firstName $lastName'.trim();

  UserEntity copyWith({
    String? username, String? email, String? firstName,
    String? lastName, String? phone, String? role, bool? isActive,
  }) => UserEntity(
    id: id,
    username: username ?? this.username,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
    dateJoined: dateJoined,
  );

  @override
  List<Object?> get props => [id, username, email, role, isActive];
}
