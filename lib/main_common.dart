import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:setup_flavor/core/binding/main_binding.dart';
import 'package:setup_flavor/routes/app_screen.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: ScreenUtil.defaultSize,
      child: GetMaterialApp.router(
        debugShowCheckedModeBanner: false,
        getPages: AppScreen.routes,
        initialBinding: MainBinding(),
      ),
    );
  }
}
