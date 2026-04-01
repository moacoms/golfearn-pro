import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Golfearn "Green Course" 디자인 시스템
/// 골프 코스의 고급스러움을 앱에 담은 프리미엄 테마
class AppTheme {
  // ─────────────────────────────────────────────
  // Brand Colors — "Green Course" Palette
  // ─────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF065F46);      // Deep Forest Green
  static const Color primaryLight = Color(0xFF10B981);       // Emerald (밝은 액센트)
  static const Color primaryDarkColor = Color(0xFF064E3B);   // Deepest Green
  static const Color accentGold = Color(0xFFD4A853);         // Golf Gold (포인트)
  static const Color accentGoldLight = Color(0xFFF5E6C4);   // Gold 배경용

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF065F46), Color(0xFF10B981)],
  );
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A853), Color(0xFFE8C882)],
  );
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFBFC), Color(0xFFF0F2F5)],
  );

  // Background & Surface
  static const Color backgroundColor = Color(0xFFFAFBFC);   // Soft White
  static const Color surfaceColor = Colors.white;
  static const Color surfaceElevated = Color(0xFFF8FAF9);   // 살짝 초록빛 화이트

  // Semantic Colors
  static const Color secondaryColor = Color(0xFF3B82F6);     // Blue
  static const Color errorColor = Color(0xFFDC2626);         // Red
  static const Color successColor = Color(0xFF16A34A);       // Green
  static const Color warningColor = Color(0xFFEA580C);       // Orange
  static const Color infoColor = Color(0xFF0284C7);          // Sky Blue

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);        // 거의 검정
  static const Color textSecondary = Color(0xFF6B7280);      // Gray-500
  static const Color textMuted = Color(0xFF9CA3AF);          // Gray-400
  static const Color textOnPrimary = Colors.white;
  static const Color textOnGold = Color(0xFF3D2E0A);         // 골드 위 텍스트

  // Border & Divider
  static const Color borderColor = Color(0xFFE2E8F0);        // Slate-200
  static const Color borderLight = Color(0xFFF1F5F9);        // Slate-100
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF065F46).withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF065F46).withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get bottomNavShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];

  // ─────────────────────────────────────────────
  // Radius
  // ─────────────────────────────────────────────
  static double get radiusXs => 6.r;
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 20.r;
  static double get radiusFull => 100.r;

  // ─────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFD1FAE5),
        secondary: accentGold,
        onSecondary: textOnGold,
        surface: surfaceColor,
        onSurface: textPrimary,
        error: errorColor,
        onError: Colors.white,
      ),

      // AppBar — 깔끔한 화이트 + 그림자 없음
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Noto Sans KR',
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),

      // Card — 부드러운 그림자 + 둥근 모서리
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button — 그라데이션 느낌의 프라이머리
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans KR',
            letterSpacing: -0.2,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans KR',
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Noto Sans KR',
          ),
        ),
      ),

      // Input — 깔끔한 라운드 필드
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: textMuted,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Bottom Navigation — 사용하지 않음 (커스텀 플로팅 바 사용)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Noto Sans KR',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w400,
          fontFamily: 'Noto Sans KR',
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: primaryColor,
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'Noto Sans KR',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        side: BorderSide.none,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Text Theme — 타이틀 굵게, 본문 가볍게
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
          letterSpacing: -0.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
        ),
        titleMedium: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
        ),
        titleSmall: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          fontFamily: 'Noto Sans KR',
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: 'Noto Sans KR',
        ),
        labelMedium: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          fontFamily: 'Noto Sans KR',
        ),
        labelSmall: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textMuted,
          fontFamily: 'Noto Sans KR',
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // Dark Theme (추후 구현)
  static ThemeData get darkTheme => lightTheme;
}
