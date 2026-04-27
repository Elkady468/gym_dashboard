import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers({String? search});
  Future<UserModel> getUserById(int id);
  Future<UserModel> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final Dio _dio;
  UsersRemoteDataSourceImpl(this._dio);

  List<UserModel> _parseList(dynamic data) {
    final list = data is List ? data : (data['results'] as List? ?? []);
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<UserModel>> getUsers({String? search}) async {
    try {
      final res = await _dio.get(AppConstants.usersEndpoint,
          queryParameters: search != null && search.isNotEmpty
              ? {'search': search}
              : null);
      return _parseList(res.data);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      final res = await _dio.get('${AppConstants.usersEndpoint}$id/');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put('${AppConstants.usersEndpoint}$id/', data: data);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('${AppConstants.usersEndpoint}$id/');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
