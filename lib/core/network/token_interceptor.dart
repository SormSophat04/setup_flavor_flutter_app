import 'package:dio/dio.dart';
import 'package:setup_flavor/core/network/jwt_tokens.dart';
import 'package:setup_flavor/core/storage/secure_storage.dart';

class TokenInterceptor extends Interceptor {
  static const _retriedRequestKey = 'token_interceptor_retried_request';
  final Dio _dio;
  final SecureStorage storage;

  TokenInterceptor(this._dio, {SecureStorage? storage})
    : storage = storage ?? SecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.accessToken;
    final hasAuthHeader = options.headers.keys.any(
      (key) => key.toString().toLowerCase() == 'authorization',
    );

    if (token != null && !hasAuthHeader) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path == '/auth/refresh';
    final alreadyRetried =
        err.requestOptions.extra[_retriedRequestKey] == true;

    if (isUnauthorized && !isRefreshCall && !alreadyRetried) {
      final refresh = await _refreshToken();

      if (refresh) {
        final token = await storage.accessToken;
        err.requestOptions
          ..headers['Authorization'] = 'Bearer $token'
          ..extra[_retriedRequestKey] = true;

        final cloneReq = await _dio.fetch(err.requestOptions);
        return handler.resolve(cloneReq);
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storage.refreshToken;
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );
      final tokens = JwtTokensParser.tryParse(response.data);
      if (tokens == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message:
              'Refresh response is missing access and refresh tokens. '
              'Expected keys: accessToken/refreshToken or access_token/refresh_token.',
        );
      }

      await storage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return true;
    } on DioException catch (_) {
      await storage.clearTokens();
      return false;
    }
  }
}
