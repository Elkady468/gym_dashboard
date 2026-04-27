import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id, required super.username, required super.email,
    required super.firstName, required super.lastName,
    super.phone, super.role, super.isActive, super.dateJoined,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as int? ?? 0,
        username: j['username'] as String? ?? '',
        email: j['email'] as String? ?? '',
        firstName: j['first_name'] as String? ?? '',
        lastName: j['last_name'] as String? ?? '',
        phone: j['phone'] as String?,
        role: j['role'] as String? ?? 'member',
        isActive: j['is_active'] as bool? ?? true,
        dateJoined: j['date_joined'] != null
            ? DateTime.tryParse(j['date_joined'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'username': username, 'email': email,
        'first_name': firstName, 'last_name': lastName,
        if (phone != null) 'phone': phone,
        'role': role, 'is_active': isActive,
      };
}
