import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setup_flavor/core/network/api_client.dart';
import 'package:setup_flavor/core/network/api_config.dart';
import 'package:setup_flavor/core/storage/secure_storage.dart';
import 'package:setup_flavor/data/model/auth_model.dart';
import 'package:setup_flavor/data/repository/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    test('login calls API and saves jwt tokens', () async {
      final adapter = LoginRecordingAdapter(
        statusCode: 200,
        payload: {'accessToken': 'access-1', 'refreshToken': 'refresh-1'},
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(dio: dio, token: '');
      final storage = InMemorySecureStorage();
      final repository = AuthRepository(apiClient: apiClient, storage: storage);

      await repository.login(
        AuthModel(email: 'john@doe.com', password: '123456'),
      );

      expect(adapter.lastRequestOptions?.method, 'POST');
      expect(adapter.lastRequestOptions?.path, ApiConfig.login);
      expect(
        adapter.lastDecodedBody,
        {'email': 'john@doe.com', 'password': '123456'},
      );
      expect(await storage.accessToken, 'access-1');
      expect(await storage.refreshToken, 'refresh-1');
    });

    test('login rethrows DioException and does not save tokens on API error', () async {
      final adapter = LoginRecordingAdapter(
        statusCode: 401,
        payload: {'message': 'invalid credentials'},
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(dio: dio, token: '');
      final storage = InMemorySecureStorage();
      final repository = AuthRepository(apiClient: apiClient, storage: storage);

      await expectLater(
        repository.login(
          AuthModel(email: 'john@doe.com', password: 'wrong-password'),
        ),
        throwsA(isA<DioException>()),
      );
      expect(await storage.accessToken, isNull);
      expect(await storage.refreshToken, isNull);
    });

    test('login reads jwt tokens from nested data payload', () async {
      final adapter = LoginRecordingAdapter(
        statusCode: 200,
        payload: {
          'data': {'access_token': 'access-2', 'refresh_token': 'refresh-2'},
        },
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(dio: dio, token: '');
      final storage = InMemorySecureStorage();
      final repository = AuthRepository(apiClient: apiClient, storage: storage);

      await repository.login(
        AuthModel(email: 'john@doe.com', password: '123456'),
      );

      expect(await storage.accessToken, 'access-2');
      expect(await storage.refreshToken, 'refresh-2');
    });

    test('logout calls API and clears local tokens', () async {
      final adapter = LoginRecordingAdapter(
        statusCode: 200,
        payload: {'ok': true},
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(dio: dio, token: '');
      final storage = InMemorySecureStorage(
        accessToken: 'access-before',
        refreshToken: 'refresh-before',
      );
      final repository = AuthRepository(apiClient: apiClient, storage: storage);

      await repository.logout();

      expect(adapter.lastRequestOptions?.method, 'POST');
      expect(adapter.lastRequestOptions?.path, ApiConfig.logout);
      expect(await storage.accessToken, isNull);
      expect(await storage.refreshToken, isNull);
    });

    test('logout clears local tokens even when API call fails', () async {
      final adapter = LoginRecordingAdapter(
        statusCode: 500,
        payload: {'message': 'server error'},
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(dio: dio, token: '');
      final storage = InMemorySecureStorage(
        accessToken: 'access-before',
        refreshToken: 'refresh-before',
      );
      final repository = AuthRepository(apiClient: apiClient, storage: storage);

      await expectLater(repository.logout(), throwsA(isA<DioException>()));
      expect(await storage.accessToken, isNull);
      expect(await storage.refreshToken, isNull);
    });
  });
}

class LoginRecordingAdapter implements HttpClientAdapter {
  LoginRecordingAdapter({required this.statusCode, required this.payload});

  final int statusCode;
  final Map<String, dynamic> payload;
  RequestOptions? lastRequestOptions;
  Map<String, dynamic>? lastDecodedBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    lastDecodedBody = await decodeRequestBody(requestStream);

    return ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class InMemorySecureStorage extends SecureStorage {
  InMemorySecureStorage({String? accessToken, String? refreshToken})
    : _accessToken = accessToken,
      _refreshToken = refreshToken;

  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<String?> get accessToken async => _accessToken;

  @override
  Future<String?> get refreshToken async => _refreshToken;

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

Future<Map<String, dynamic>?> decodeRequestBody(
  Stream<Uint8List>? requestStream,
) async {
  if (requestStream == null) {
    return null;
  }

  final bytes = <int>[];
  await for (final chunk in requestStream) {
    bytes.addAll(chunk);
  }

  if (bytes.isEmpty) {
    return null;
  }

  final decoded = jsonDecode(utf8.decode(bytes));
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }

  if (decoded is Map) {
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }

  return null;
}
