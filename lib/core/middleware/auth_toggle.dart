import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:setup_flavor/core/storage/secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:setup_flavor/routes/app_route.dart';

class AuthToggle extends GetMiddleware {
  final SecureStorage storage;

  AuthToggle(this.storage);

  @override
  RouteSettings? redirect(String? route) {
    return null;
  }

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final currentPath = Uri.parse(route.locationString).path;
    final hasValidAccessToken = await _hasValidAccessToken();

    if (!hasValidAccessToken && _requiresAuth(currentPath)) {
      return GetNavConfig.fromRoute(AppRoute.login);
    }

    if (hasValidAccessToken && _isAuthScreen(currentPath)) {
      return GetNavConfig.fromRoute(AppRoute.mainLayout);
    }

    return route;
  }

  bool _requiresAuth(String route) {
    return !_isAuthScreen(route);
  }

  bool _isAuthScreen(String route) {
    return route == AppRoute.login || route == AppRoute.register;
  }

  Future<bool> _hasValidAccessToken() async {
    final token = await storage.accessToken;
    if (token == null || token.trim().isEmpty) {
      return false;
    }

    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }
}
