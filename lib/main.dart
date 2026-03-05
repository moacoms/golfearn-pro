import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 환경변수 로드
  await dotenv.load(fileName: ".env");
  
  // Supabase 초기화 (기존 Golfearn 프로젝트와 동일한 인스턴스)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(
    const ProviderScope(
      child: GolfearnProApp(),
    ),
  );
}

// Supabase 클라이언트 글로벌 액세스
final supabase = Supabase.instance.client;