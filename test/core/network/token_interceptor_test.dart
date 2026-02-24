import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setup_flavor/core/network/token_interceptor.dart';
import 'package:setup_flavor/core/storage/secure_storage.dart';

void main() {
  group('TokenInterceptor jwt refresh', () {
    test('refreshes jwt and retries original request after 401', () async {
      final storage = InMemorySecureStorage(
        accessToken: 'old-access',
        refreshToken: 'refresh-token',
      );
      final adapter = InMemoryAdapter(refreshSucceeds: true);
      final dio = Dio();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(TokenInterceptor(dio, storage: storage));

      final response = await dio.get('/protected');

      expect(response.statusCode, 200);
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['ok'], isTrue);
      expect(await storage.accessToken, 'new-access');
      expect(await storage.refreshToken, 'new-refresh');
      expect(adapter.protectedRequestCount, 2);
      expect(adapter.refreshRequestCount, 1);
      expect(adapter.lastRefreshAuthHeader, 'Bearer refresh-token');
      expect(adapter.lastRefreshBody, {'refreshToken': 'refresh-token'});
      expect(adapter.lastProtectedAuthHeader, 'Bearer new-access');
    });

    test('refresh handles nested token payload before retrying request', () async {
      final storage = InMemorySecureStorage(
        accessToken: 'old-access',
        refreshToken: 'refresh-token',
      );
      final adapter = InMemoryAdapter(
        refreshSucceeds: true,
        refreshSuccessPayload: {
          'data': {'access_token': 'new-access', 'refresh_token': 'new-refresh'},
        },
      );
      final dio = Dio();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(TokenInterceptor(dio, storage: storage));

      final response = await dio.get('/protected');

      expect(response.statusCode, 200);
      expect(await storage.accessToken, 'new-access');
      expect(await storage.refreshToken, 'new-refresh');
      expect(adapter.protectedRequestCount, 2);
      expect(adapter.lastProtectedAuthHeader, 'Bearer new-access');
    });

    test('clears jwt tokens and rethrows when refresh fails', () async {
      final storage = InMemorySecureStorage(
        accessToken: 'old-access',
        refreshToken: 'refresh-token',
      );
      final adapter = InMemoryAdapter(refreshSucceeds: false);
      final dio = Dio();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(TokenInterceptor(dio, storage: storage));

      await expectLater(
        dio.get('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(storage.cleared, isTrue);
      expect(await storage.accessToken, isNull);
      expect(await storage.refreshToken, isNull);
      expect(adapter.protectedRequestCount, 1);
      expect(adapter.refreshRequestCount, 1);
    });

    test('does not call refresh endpoint when refresh token is missing', () async {
      final storage = InMemorySecureStorage(accessToken: 'old-access');
      final adapter = InMemoryAdapter(refreshSucceeds: true);
      final dio = Dio();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(TokenInterceptor(dio, storage: storage));

      await expectLater(
        dio.get('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.protectedRequestCount, 1);
      expect(adapter.refreshRequestCount, 0);
    });
  });
}

class InMemorySecureStorage extends SecureStorage {
  InMemorySecureStorage({String? accessToken, String? refreshToken})
    : _accessToken = accessToken,
      _refreshToken = refreshToken;

  String? _accessToken;
  String? _refreshToken;
  bool cleared = false;

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
    cleared = true;
    _accessToken = null;
    _refreshToken = null;
  }
}

class InMemoryAdapter implements HttpClientAdapter {
  InMemoryAdapter({
    required this.refreshSucceeds,
    this.refreshSuccessPayload = const <String, dynamic>{
      'accessToken': 'new-access',
      'refreshToken': 'new-refresh',
    },
  });

  final bool refreshSucceeds;
  final Map<String, dynamic> refreshSuccessPayload;
  int protectedRequestCount = 0;
  int refreshRequestCount = 0;
  String? lastRefreshAuthHeader;
  Object? lastRefreshBody;
  String? lastProtectedAuthHeader;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/refresh') {
      refreshRequestCount += 1;
      lastRefreshAuthHeader = options.headers['Authorization']?.toString();
      lastRefreshBody = options.data;

      if (!refreshSucceeds) {
        return _jsonResponse(401, {'message': 'refresh failed'});
      }

      return _jsonResponse(200, refreshSuccessPayload);
    }

    if (options.path == '/protected') {
      protectedRequestCount += 1;
      lastProtectedAuthHeader = options.headers['Authorization']?.toString();

      if (protectedRequestCount == 1) {
        return _jsonResponse(401, {'message': 'access token expired'});
      }

      if (lastProtectedAuthHeader == 'Bearer new-access') {
        return _jsonResponse(200, {'ok': true});
      }

      return _jsonResponse(401, {'message': 'invalid token'});
    }

    return _jsonResponse(404, {'message': 'not found'});
  }

  ResponseBody _jsonResponse(int statusCode, Map<String, dynamic> payload) {
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
