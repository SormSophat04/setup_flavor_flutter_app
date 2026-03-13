import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_device/safe_device.dart';
import 'package:setup_flavor/core/security/security_service.dart';
import 'package:setup_flavor/routes/app_route.dart';

class SecurityMiddleware extends GetMiddleware {
  final SecurityService _securityService = SecurityService();

  @override
  RouteSettings? redirect(String? route) {
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig? route) async {
    try {
      if (await SafeDevice.isDevelopmentModeEnable) {
        await _securityService.enforceSecurity();
        return route;
      }
    } on DioException {
      return GetNavConfig.fromRoute(AppRoute.securityBlocked);
    } catch (e) {
      return GetNavConfig.fromRoute(AppRoute.securityBlocked);
    }
    return null;
  }
}
