import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class GolfearnProApp extends ConsumerWidget {
  const GolfearnProApp({super.key});

  // 모바일 기준 디자인 폭. 데스크탑에서 과도하게 확대되는 걸 막기 위해
  // 이보다 넓은 화면에서는 이 폭으로 콘텐츠를 제한하고 가운데 정렬.
  static const double _phoneWidth = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

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
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final isWide = mq.size.width > _phoneWidth;

        final screenUtil = ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, _) => child ?? const SizedBox.shrink(),
        );

        if (!isWide) return screenUtil;

        return ColoredBox(
          color: const Color(0xFFE5E7EB),
          child: Center(
            child: SizedBox(
              width: _phoneWidth,
              height: mq.size.height,
              child: MediaQuery(
                data: mq.copyWith(
                  size: Size(_phoneWidth, mq.size.height),
                ),
                child: screenUtil,
              ),
            ),
          ),
        );
      },
    );
  }
}