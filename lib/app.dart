import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class GolfearnProApp extends ConsumerWidget {
  const GolfearnProApp({super.key});

  // iPhone 13 기준 디자인 폭/높이
  static const double _baseDesignWidth = 390;
  static const double _baseDesignHeight = 844;

  // 넓은 화면에서 고정할 최대 확대 배율. 1.3 = 데스크탑에서도 텍스트/UI가
  // 모바일의 1.3배 수준만 확대되도록 유지 (iPhone 13 기준 화면 507px까지 자연 스케일).
  static const double _maxScale = 1.3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final naturalCutoff = _baseDesignWidth * _maxScale;

        // 좁은 화면: 자연 스케일 (screenWidth / 390)
        // 넓은 화면: designSize를 비례 확대하여 스케일을 _maxScale로 고정
        final designWidth = screenWidth > naturalCutoff
            ? screenWidth / _maxScale
            : _baseDesignWidth;
        final designHeight =
            designWidth * (_baseDesignHeight / _baseDesignWidth);

        return ScreenUtilInit(
          designSize: Size(designWidth, designHeight),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'Golfearn',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              routerConfig: router,
              debugShowCheckedModeBanner: false,
              locale: const Locale('ko', 'KR'),
              supportedLocales: const [
                Locale('ko', 'KR'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        );
      },
    );
  }
}