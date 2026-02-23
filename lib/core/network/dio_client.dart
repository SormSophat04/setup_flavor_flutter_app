import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:setup_flavor/core/config/app_config.dart';
import 'package:setup_flavor/core/network/api_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  late Dio dio;
  DioClient._internal();

  final _secureStorage = const FlutterSecureStorage();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
        responseType: ResponseType.json,
      ),
    );

    if (AppConfig.env.enableLog) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // final token = await _instance._secureStorage.read(key: 'token');
            final token = await _readTokenFromStorage();
            options.headers['Authorization'] = 'Bearer $token';
            return handler.next(options);
          },
          onResponse: (response, handler) {
            return handler.next(response);
          },
          onError: (DioException error, handler) {
            return handler.next(error);
          },
        ),
      );
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          requestHeader: true,
          responseBody: true,
          responseHeader: true,
          error: true,
        ),
      );
    }
    return dio;
  }

  static Future<String> _readTokenFromStorage() async {
    try {
      final token = await _instance._secureStorage.read(key: 'token');
      return token ?? '';
    } on DioException catch (e) {
      log('Error reading token from storage: ${e.message}');
      return '';
    }
  }
}
