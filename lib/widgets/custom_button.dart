import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool? isloading;
  const CustomButton({
    super.key,
    required this.label,
    this.onTap,
    this.isloading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isloading == true ? null : onTap,
      child: AnimatedContainer(
        height: 50.0,
        width: double.infinity,
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isloading == true ? Colors.blue[300] : const Color(0xFF007BFF),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: isloading == true
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
      ),
    );
  }
}
