import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:setup_flavor/core/utils/validator.dart';
import 'package:setup_flavor/modules/auth/controller/auth_controller.dart';
import 'package:setup_flavor/routes/app_route.dart';
import 'package:setup_flavor/widgets/custom_button.dart';
import 'package:setup_flavor/widgets/custom_text_field.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : AuthController(),
      autoRemove: false,
      builder: (controller) => Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: controller.signUpFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  const SizedBox(height: 46.0),
                  CustomTextField(
                    hintText: 'Email',
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validator.validateEmail,
                  ),
                  const SizedBox(height: 16.0),
                  CustomTextField(
                    hintText: 'Password',
                    controller: controller.passwordController,
                    obscureText: true,
                    validator: Validator.validatePassword,
                  ),
                  const SizedBox(height: 30.0),
                  CustomButton(
                    label: 'Sign Up',
                    onTap: () => controller.signUp(),
                    isloading: controller.loading.value,
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Get.rootDelegate.toNamed(AppRoute.login);
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
