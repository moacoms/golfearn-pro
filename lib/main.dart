import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한글 폰트 사전 로드 (CanvasKit IME 조합 깨짐 방지)
  await _loadKoreanFont();

  // 환경변수 로드
  await dotenv.load(fileName: ".env");

  // Supabase 초기화 (기존 Golfearn 프로젝트와 동일한 인스턴스)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
      autoRefreshToken: true,
    ),
  );

  runApp(
    const ProviderScope(
      child: GolfearnProApp(),
    ),
  );
}

/// 한글 폰트를 앱 시작 전에 강제 로드
/// CanvasKit 렌더러가 한글 IME 조합 중 글리프를 찾을 수 있도록 함
Future<void> _loadKoreanFont() async {
  try {
    final fontLoader = FontLoader('Noto Sans KR');
    final fontData = rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf');
    fontLoader.addFont(fontData.then((data) => data.buffer.asByteData()));
    await fontLoader.load();
  } catch (e) {
    print('한글 폰트 로드 실패 (무시 가능): $e');
  }
}

// Supabase 클라이언트 글로벌 액세스
final supabase = Supabase.instance.client;