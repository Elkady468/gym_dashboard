import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel> login({required String username, required String password});
  Future<AdminUserModel> getMe();
  Future<void> logout({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<TokenModel> login({required String username, required String password}) async {
    try {
      final res = await _dio.post(AppConstants.loginEndpoint,
          data: {'username': username, 'password': password});
      return TokenModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<AdminUserModel> getMe() async {
    try {
      final res = await _dio.get(AppConstants.meEndpoint);
      return AdminUserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(AppConstants.blacklistEndpoint,
          data: {'refresh': refreshToken});
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
