import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:setup_flavor/modules/auth/controller/auth_controller.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init:
          Get.isRegistered<AuthController>()
              ? Get.find<AuthController>()
              : AuthController(),
      autoRemove: false,
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Main Layout'),
          actions: [
            IconButton(
              onPressed: () {
                controller.logout();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const Center(child: Text('This is the main layout.')),
      ),
    );
  }
}
