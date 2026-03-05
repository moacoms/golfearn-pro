import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Golfearn 브랜드 테마
/// 기존 웹사이트와 일관된 디자인 시스템
class AppTheme {
  // 브랜드 컬러 (웹사이트와 동일)
  static const Color primaryColor = Color(0xFF10B981); // Emerald-500
  static const Color primaryDarkColor = Color(0xFF059669); // Emerald-600
  static const Color secondaryColor = Color(0xFF3B82F6); // Blue-500
  static const Color backgroundColor = Color(0xFFF9FAFB); // Gray-50
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444); // Red-500
  static const Color successColor = Color(0xFF22C55E); // Green-500
  static const Color warningColor = Color(0xFFF59E0B); // Amber-500
  
  // 텍스트 컬러
  static const Color textPrimaryColor = Color(0xFF111827); // Gray-900
  static const Color textSecondaryColor = Color(0xFF6B7280); // Gray-500
  static const Color textMutedColor = Color(0xFF9CA3AF); // Gray-400
  
  // 보더 컬러
  static const Color borderColor = Color(0xFFE5E7EB); // Gray-300
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // ColorScheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
        background: backgroundColor,
        onBackground: textPrimaryColor,
        error: errorColor,
        onError: Colors.white,
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
        iconTheme: const IconThemeData(
          color: textPrimaryColor,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: borderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: borderColor),
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: TextStyle(
          color: textMutedColor,
          fontSize: 14.sp,
        ),
        labelStyle: TextStyle(
          color: textSecondaryColor,
          fontSize: 14.sp,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMutedColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          fontFamily: 'Pretendard',
        ),
      ),
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        displayMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        displaySmall: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        headlineLarge: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        headlineMedium: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        headlineSmall: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        titleLarge: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        titleMedium: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        titleSmall: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: textSecondaryColor,
          fontFamily: 'Pretendard',
        ),
        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
          fontFamily: 'Pretendard',
        ),
        labelSmall: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textSecondaryColor,
          fontFamily: 'Pretendard',
        ),
      ),
    );
  }
  
  // Dark Theme (추후 구현)
  static ThemeData get darkTheme {
    return lightTheme; // 일단 라이트 테마와 동일하게 설정
  }
}