import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? 
        (isOutlined ? Colors.transparent : const Color(0xFF10B981));
    final txtColor = textColor ?? 
        (isOutlined ? const Color(0xFF10B981) : Colors.white);

    return SizedBox(
      height: 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          elevation: 0,
          side: isOutlined 
              ? const BorderSide(color: Color(0xFF10B981))
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          disabledBackgroundColor: isOutlined 
              ? Colors.transparent
              : Colors.grey[300],
          disabledForegroundColor: Colors.grey[500],
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOutlined ? const Color(0xFF10B981) : Colors.white,
                  ),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}