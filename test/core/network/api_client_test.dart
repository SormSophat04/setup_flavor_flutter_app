import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setup_flavor/core/network/api_client.dart';

void main() {
  group('ApiClient', () {
    test('factory applies baseUrl to injected dio', () async {
      final dio = Dio();

      ApiClient(dio: dio, baseUrl: 'https://unit.test', token: '');

      expect(dio.options.baseUrl, 'https://unit.test');
    });

    test('get sends query and bearer token when token is set', () async {
      final adapter = RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(dio: dio, token: 'jwt-token');

      final response = await client.get(
        '/users',
        queryParameters: {'page': 1},
      );

      expect(response.statusCode, 200);
      expect(adapter.lastRequestOptions?.method, 'GET');
      expect(adapter.lastRequestOptions?.queryParameters, {'page': 1});
      expect(
        readHeader(adapter.lastRequestOptions!, 'Authorization'),
        'Bearer jwt-token',
      );
      expect(readHeader(adapter.lastRequestOptions!, 'Accept'), 'application/json');
    });

    test('post sends request body and auth header', () async {
      final adapter = RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(dio: dio, token: 'jwt-token');

      await client.post(
        '/login',
        body: {'email': 'a@b.com', 'password': '123456'},
      );

      expect(adapter.lastRequestOptions?.method, 'POST');
      expect(
        adapter.lastDecodedBody,
        {'email': 'a@b.com', 'password': '123456'},
      );
      expect(
        readHeader(adapter.lastRequestOptions!, 'Authorization'),
        'Bearer jwt-token',
      );
    });

    test('does not send authorization when token is empty', () async {
      final adapter = RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://unit.test'));
      dio.httpClientAdapter = adapter;
      final client = ApiClient(dio: dio, token: '');

      await client.get('/public');

      expect(readHeader(adapter.lastRequestOptions!, 'Authorization'), isNull);
    });
  });

  group('ErrorInterceptor', () {
    test('throws UnauthorizedException with server message on 401', () {
      final interceptor = ErrorInterceptor(Dio());
      final requestOptions = RequestOptions(path: '/secure');
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'token expired'},
        ),
      );

      expect(
        () => interceptor.onError(err, ErrorInterceptorHandler()),
        throwsA(
          isA<UnauthorizedException>().having(
            (e) => e.toString(),
            'message',
            'token expired',
          ),
        ),
      );
    });

    test('throws ConnectionTimeOutException on connection timeout', () {
      final interceptor = ErrorInterceptor(Dio());
      final requestOptions = RequestOptions(path: '/timeout');
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => interceptor.onError(err, ErrorInterceptorHandler()),
        throwsA(isA<ConnectionTimeOutException>()),
      );
    });

    test('throws NoInternetConnectionException on connection error', () {
      final interceptor = ErrorInterceptor(Dio());
      final requestOptions = RequestOptions(path: '/offline');
      final err = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      expect(
        () => interceptor.onError(err, ErrorInterceptorHandler()),
        throwsA(isA<NoInternetConnectionException>()),
      );
    });
  });
}

class RecordingAdapter implements HttpClientAdapter {
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
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
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

String? readHeader(RequestOptions options, String key) {
  for (final entry in options.headers.entries) {
    if (entry.key.toString().toLowerCase() == key.toLowerCase()) {
      return entry.value?.toString();
    }
  }
  return null;
}
