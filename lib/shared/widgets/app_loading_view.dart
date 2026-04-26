import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';

/// 앱 전반의 로딩 인디케이터 통일.
/// 직접 `CircularProgressIndicator()` 대신 사용.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 2.5,
    this.padding,
    this.message,
  });

  /// 인디케이터 사각 크기. 기본 28.w.
  final double? size;

  /// 인디케이터 색상. 기본 [AppTheme.primaryColor].
  /// splash·다크 배경 등에서만 흰색 등으로 오버라이드.
  final Color? color;

  /// 선 굵기.
  final double strokeWidth;

  /// 외곽 padding.
  final EdgeInsetsGeometry? padding;

  /// 인디케이터 아래에 표시할 한 줄 메시지(선택).
  final String? message;

  /// 페이지 전체를 차지하는 가운데 정렬 로딩.
  static Widget centered({String? message}) {
    return Center(child: AppLoadingView(message: message));
  }

  /// 작은 인라인 로딩 (리스트 하단 등).
  static Widget compact() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(child: AppLoadingView(strokeWidth: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size ?? 28.w,
      height: size ?? 28.w,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.primaryColor,
        ),
      ),
    );

    final body = message == null
        ? indicator
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              SizedBox(height: 12.h),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          );

    if (padding != null) {
      return Padding(padding: padding!, child: body);
    }
    return body;
  }
}
