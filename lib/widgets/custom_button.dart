import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        height: 50.h,
        width: double.infinity,
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        decoration: BoxDecoration(
          color: isloading == true ? Colors.blue[200] : const Color(0xFF007BFF),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: isloading == true
            ? Image.network(
                'https://cdn.pixabay.com/animation/2022/07/29/03/42/03-42-05-37_512.gif',
                width: 52.w,
                fit: BoxFit.cover,
              )
            : Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
      ),
    );
  }
}
