import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  static Dio create({
    required String Function() getAccessToken,
    required String Function() getRefreshToken,
    required Future<void> Function(String, String) onTokenRefreshed,
    required Future<void> Function() onLogout,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    // ── Auth Interceptor ───────────────────────────────────────────────────
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = getAccessToken();
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refresh = getRefreshToken();
          if (refresh.isNotEmpty) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
              final res = await refreshDio.post(
                AppConstants.refreshEndpoint,
                data: {'refresh': refresh},
              );
              final newAccess  = res.data['access']  as String;
              final newRefresh = res.data['refresh'] as String? ?? refresh;
              await onTokenRefreshed(newAccess, newRefresh);
              final opts = e.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccess';
              return handler.resolve(await dio.fetch(opts));
            } catch (_) {
              await onLogout();
            }
          }
        }
        handler.next(e);
      },
    ));

    dio.interceptors.add(PrettyDioLogger(
      requestBody: true, responseBody: false,
      error: true, compact: true, requestHeader: false,
    ));

    return dio;
  }
}

/// Converts Dio errors into typed exceptions for repository handling
Never handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      throw const NetworkException();
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      String msg = 'Server error';
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        msg = d['detail'] ?? d['message'] ?? d['error'] ??
              d.values.firstOrNull?.toString() ?? msg;
      }
      if (code == 401 || code == 403) throw AuthException(msg);
      throw ServerException(msg, statusCode: code);
    default:
      throw const ServerException('Unexpected error');
  }
}
