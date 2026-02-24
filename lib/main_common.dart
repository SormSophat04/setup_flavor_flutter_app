import 'package:flutter/material.dart';
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
    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      getPages: AppScreen.routes,
      initialBinding: MainBinding(),
    );
  }
}
