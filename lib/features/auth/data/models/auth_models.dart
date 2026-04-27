import '../../domain/entities/auth_entities.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.role,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> j) => AdminUserModel(
        id: j['id'] as int? ?? 0,
        username: j['username'] as String? ?? '',
        email: j['email'] as String? ?? '',
        firstName: j['first_name'] as String? ?? '',
        lastName: j['last_name'] as String? ?? '',
        role: j['role'] as String? ?? 'admin',
      );
}

class TokenModel extends TokenEntity {
  const TokenModel({required super.access, required super.refresh});

  factory TokenModel.fromJson(Map<String, dynamic> j) => TokenModel(
        access: j['access'] as String? ?? '',
        refresh: j['refresh'] as String? ?? '',
      );
}
