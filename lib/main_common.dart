import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:setup_flavor/modules/main_layout/view/main_layout.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: MainLayout());
  }
}
