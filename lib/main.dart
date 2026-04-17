import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

// --dart-define 으로 주입된 값 (빌드 시), 없으면 .env fallback
const _kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _kSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 전역 에러 핸들러
  FlutterError.onError = (details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Async Error: $error');
    }
    return true;
  };

  // 한글 폰트 사전 로드 (CanvasKit IME 조합 깨짐 방지)
  await _loadKoreanFont();

  // 환경변수: dart-define 우선, 없으면 .env fallback (로컬 개발용)
  String supabaseUrl = _kSupabaseUrl;
  String supabaseAnonKey = _kSupabaseAnonKey;

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    try {
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    } catch (_) {}
  }

  // Supabase 초기화
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
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
  }
}

// Supabase 클라이언트 글로벌 액세스
final supabase = Supabase.instance.client;