import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:setup_flavor/core/network/dio_client.dart';

class ApiClient {
  Dio _dio;
  String _token = '';

  ApiClient._internal({Dio? dio}) : _dio = dio ?? DioClient.create();

  static final _singleton = ApiClient._internal();

  factory ApiClient({String? baseUrl, String? token, Dio? dio}) {
    if (dio != null) _singleton._dio = dio;
    if (baseUrl != null) _singleton._dio.options.baseUrl = baseUrl;
    if (token != null) _singleton._token = token;
    return _singleton;
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_token.isNotEmpty) await setUserAccessToken(_token);
    return await _dio.get(url, queryParameters: queryParameters);
  }

  Future<Response> post(
    String url, {
    body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (_token.isNotEmpty) await setUserAccessToken(_token);
    return await _dio.post(
      url,
      queryParameters: queryParameters,
      data: body,
      options: options,
    );
  }

  Future<Response> patch(
    String url, {
    body,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_token.isNotEmpty) await setUserAccessToken(_token);
    return await _dio.patch(url, queryParameters: queryParameters, data: body);
  }

  Future<Response> put(
    String url, {
    body,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_token.isNotEmpty) await setUserAccessToken(_token);
    return await _dio.put(url, queryParameters: queryParameters, data: body);
  }

  Future<Response> delete(
    String url, {
    body,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (_token.isNotEmpty) await setUserAccessToken(_token);
    return await _dio.delete(url, queryParameters: queryParameters, data: body);
  }

  Future<void> setUserAccessToken(String accessToken) async {
    if (accessToken.isNotEmpty) {
      _dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
    }
  }
}

class ErrorInterceptor extends Interceptor {
  final Dio dio;

  ErrorInterceptor(this.dio);

  String? _responseMessage(dynamic data) {
    final Map<String, dynamic>? mapData = _asStringKeyMap(data);
    if (mapData != null) {
      final dynamic message = mapData['message'] ?? mapData['error'];
      if (message != null) {
        final String text = message.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    if (data is String) {
      final String text = data.trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  Map<String, dynamic>? _asStringKeyMap(dynamic value) {
    if (value is! Map) {
      return null;
    }
    final Map<String, dynamic> normalized = <String, dynamic>{};
    value.forEach((dynamic key, dynamic val) {
      if (key != null) {
        normalized[key.toString()] = val;
      }
    });
    return normalized;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('err.response $err', name: 'ApiClient');
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        throw ConnectionTimeOutException(err.requestOptions);
      case DioExceptionType.sendTimeout:
        throw SendTimeOutException(err.requestOptions);
      case DioExceptionType.receiveTimeout:
        throw ReceiveTimeOutException(err.requestOptions);
      case DioExceptionType.badResponse:
        final String? messageErr = _responseMessage(err.response?.data);
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(
              err.requestOptions,
              messageErr: messageErr,
              response: err.response,
            );
          case 401:
            throw UnauthorizedException(
              err.requestOptions,
              messageErr: messageErr,
              response: err.response,
            );
          case 404:
            throw NotFoundException(
              err.requestOptions,
              messageErr: messageErr,
              response: err.response,
            );
          case 409:
            throw ConflictException(
              err.requestOptions,
              messageErr: messageErr,
              response: err.response,
            );
          case 500:
            throw InternalServerErrorException(
              err.requestOptions,
              messageErr: messageErr,
              response: err.response,
            );
        }
        break;
      case DioExceptionType.cancel:
        throw SomeThingWentWrongException(err.requestOptions);

      case DioExceptionType.unknown:
        throw SomeThingWentWrongException(err.requestOptions);
      case DioExceptionType.badCertificate:
        throw SomeThingWentWrongException(err.requestOptions);
      case DioExceptionType.connectionError:
        throw NoInternetConnectionException(err.requestOptions);
    }
    return handler.next(err);
  }
}

class ConnectionTimeOutException extends DioException {
  ConnectionTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Connection Timed out, Please try again';
  }
}

class SendTimeOutException extends DioException {
  SendTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Send Timed out, Please try again';
  }
}

class ReceiveTimeOutException extends DioException {
  ReceiveTimeOutException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Receive Timed out, Please try again';
  }
}

//**********-----STATUS CODE ERROR HANDLERS--------**********

class BadRequestException extends DioException {
  BadRequestException(RequestOptions r, {this.messageErr, super.response})
    : super(requestOptions: r);
  final String? messageErr;

  @override
  String toString() {
    return messageErr ?? 'Invalid request';
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException(
    RequestOptions r, {
    this.messageErr,
    super.response,
  }) : super(requestOptions: r);
  final String? messageErr;

  @override
  String toString() {
    return messageErr ??
        'Internal server error occurred, please try again later.';
  }
}

class ConflictException extends DioException {
  ConflictException(RequestOptions r, {this.messageErr, super.response})
    : super(requestOptions: r);
  final String? messageErr;

  @override
  String toString() {
    return messageErr ?? 'Conflict occurred';
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions r, {this.messageErr, super.response})
    : super(requestOptions: r);
  final String? messageErr;

  @override
  String toString() {
    return messageErr ?? 'Access denied';
  }
}

class NotFoundException extends DioException {
  NotFoundException(RequestOptions r, {this.messageErr, super.response})
    : super(requestOptions: r);
  final String? messageErr;

  @override
  String toString() {
    return messageErr ?? 'The requested information could not be found';
  }
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'No internet connection detected, please try again.';
  }
}

class SomeThingWentWrongException extends DioException {
  SomeThingWentWrongException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Something went wrong, please try again';
  }
}
