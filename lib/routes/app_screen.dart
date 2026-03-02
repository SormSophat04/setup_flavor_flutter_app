import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:setup_flavor/core/binding/main_binding.dart';
import 'package:setup_flavor/core/middleware/auth_toggle.dart';
import 'package:setup_flavor/core/middleware/security_middleware.dart';
import 'package:setup_flavor/core/storage/secure_storage.dart';
import 'package:setup_flavor/modules/auth/view/login_view.dart';
import 'package:setup_flavor/modules/auth/view/sign_up_view.dart';
import 'package:setup_flavor/modules/main_layout/view/main_layout.dart';
import 'package:setup_flavor/modules/security/view/blocked_view.dart';
import 'package:setup_flavor/routes/app_route.dart';

class AppScreen {
  static final _authToggle = AuthToggle(SecureStorage());
  static final _securityMiddleware = SecurityMiddleware();

  static final routes = [
    GetPage(
      name: AppRoute.mainLayout,
      page: () => const MainLayout(),
      binding: MainBinding(),
      middlewares: [_authToggle, _securityMiddleware],
    ),
    GetPage(
      name: AppRoute.login,
      page: () => const LoginView(),
      binding: MainBinding(),
      middlewares: [_authToggle, _securityMiddleware],
    ),
    GetPage(
      name: AppRoute.register,
      page: () => const SignUpView(),
      binding: MainBinding(),
      middlewares: [_authToggle, _securityMiddleware],
    ),
    GetPage(
      name: AppRoute.securityBlocked,
      page: () => const BlockedView(),
      binding: MainBinding(),
      middlewares: [_securityMiddleware],
    ),
  ];
}
