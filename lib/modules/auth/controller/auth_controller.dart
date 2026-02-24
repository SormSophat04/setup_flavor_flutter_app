import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:setup_flavor/data/model/auth_model.dart';
import 'package:setup_flavor/data/repository/auth_repository.dart';
import 'package:setup_flavor/routes/app_route.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  final loading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    var isSuccess = false;
    try {
      loading.value = true;
      update();
      await _authRepository.login(
        AuthModel(
          email: emailController.text,
          password: passwordController.text,
        ),
      );
      isSuccess = true;
    } on DioException catch (e) {
      log('Login failed: ${e.message}');
    } finally {
      loading.value = false;
      update();
      if (isSuccess) {
        emailController.clear();
        passwordController.clear();
        await _replaceRoute(AppRoute.mainLayout);
      }
    }
  }

  Future<void> signUp() async {
    var isSuccess = false;
    try {
      loading.value = true;
      update();
      final authModel = AuthModel(
        email: emailController.text,
        password: passwordController.text,
      );

      final hasSession = await _authRepository.signUp(authModel);
      if (!hasSession) {
        await _authRepository.login(authModel);
      }

      isSuccess = true;
    } on DioException catch (e) {
      log('Sign-up failed: ${e.message}');
    } finally {
      loading.value = false;
      update();
      if (isSuccess) {
        emailController.clear();
        passwordController.clear();
        await _replaceRoute(AppRoute.mainLayout);
      }
    }
  }

  Future<void> logout() async {
    try {
      loading.value = true;
      update();
      await _authRepository.logout();
    } catch (e) {
      log('Logout failed: $e');
    } finally {
      loading.value = false;
      update();
      await _replaceRoute(AppRoute.login);
    }
  }

  Future<void> _replaceRoute(String routeName) async {
    if (Get.rootDelegate.navigatorKey.currentState == null) {
      return;
    }
    await Get.rootDelegate.offNamed(routeName);
  }
}
