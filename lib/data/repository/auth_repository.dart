import 'package:dio/dio.dart';
import 'package:setup_flavor/core/network/api_client.dart';
import 'package:setup_flavor/core/network/api_config.dart';
import 'package:setup_flavor/core/network/jwt_tokens.dart';
import 'package:setup_flavor/core/storage/secure_storage.dart';
import 'package:setup_flavor/data/model/auth_model.dart';

class AuthRepository {
  final ApiClient _api;
  final SecureStorage _storage;

  AuthRepository({ApiClient? apiClient, SecureStorage? storage})
    : _api = apiClient ?? ApiClient(),
      _storage = storage ?? SecureStorage();

  Future<void> login(AuthModel authModel) async {
    final res = await _api.post(ApiConfig.login, body: authModel.toJson());
    final tokens = JwtTokensParser.tryParse(res.data);
    if (tokens == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        message:
            'Login response is missing access and refresh tokens. '
            'Expected keys: accessToken/refreshToken or access_token/refresh_token.',
      );
    }

    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<bool> signUp(AuthModel authModel) async {
    final res = await _api.post(ApiConfig.register, body: authModel.toJson());
    final tokens = JwtTokensParser.tryParse(res.data);
    if (tokens == null) {
      return false;
    }

    await _storage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return true;
  }

  Future<void> logout() async {
    Object? error;
    try {
      await _api.post(ApiConfig.logout);
    } catch (e) {
      error = e;
    } finally {
      await _storage.clearTokens();
    }

    if (error != null) {
      throw error;
    }
  }
}
