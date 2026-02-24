import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:setup_flavor/data/model/auth_model.dart';
import 'package:setup_flavor/data/repository/auth_repository.dart';
import 'package:setup_flavor/modules/auth/controller/auth_controller.dart';

void main() {
  group('AuthController', () {
    setUp(() {
      Get.testMode = true;
    });

    test(
      'login sets loading true while request is in progress and false after success',
      () async {
        final completer = Completer<void>();
        final repository = FakeAuthRepository(
          onLogin: (_) => completer.future,
        );
        final controller = AuthController(authRepository: repository);
        controller.emailController.text = 'john@doe.com';
        controller.passwordController.text = '123456';

        final loginFuture = controller.login();

        expect(controller.loading.value, isTrue);
        completer.complete();
        await loginFuture;

        expect(controller.loading.value, isFalse);
        expect(repository.loginCallCount, 1);
        expect(repository.lastEmail, 'john@doe.com');
        expect(repository.lastPassword, '123456');
      },
    );

    test('login handles DioException and always resets loading', () async {
      final repository = FakeAuthRepository(
        onLogin: (_) async {
          throw DioException(requestOptions: RequestOptions(path: '/login'));
        },
      );
      final controller = AuthController(authRepository: repository);
      controller.emailController.text = 'john@doe.com';
      controller.passwordController.text = 'bad-password';

      await controller.login();

      expect(controller.loading.value, isFalse);
      expect(repository.loginCallCount, 1);
    });
  });
}

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({required this.onLogin});

  final Future<void> Function(AuthModel authModel) onLogin;
  int loginCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> login(AuthModel authModel) async {
    loginCallCount += 1;
    lastEmail = authModel.email;
    lastPassword = authModel.password;
    await onLogin(authModel);
  }
}
