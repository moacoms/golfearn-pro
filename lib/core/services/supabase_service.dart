import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

/// Supabase 서비스 프로바이더
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Supabase 서비스 클래스
/// 기존 Golfearn 웹 프로젝트와 동일한 Supabase 인스턴스 사용
class SupabaseService {
  final SupabaseClient client = supabase;
  
  // 현재 사용자
  User? get currentUser => client.auth.currentUser;
  
  // 현재 세션
  Session? get currentSession => client.auth.currentSession;
  
  // 인증 상태 스트림
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
  
  // 로그인
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // 회원가입
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }
  
  // 로그아웃
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  // 프로필 조회
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      // users 테이블이 없으면 profiles 테이블 시도
      try {
        final response = await client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();
        
        return response;
      } catch (e) {
        print('프로필 조회 실패: $e');
        return null;
      }
    }
  }
  
  // 레슨프로 여부 확인
  Future<bool> isLessonPro(String userId) async {
    try {
      final profile = await getProfile(userId);
      return profile?['is_lesson_pro'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // 학생 여부 확인
  Future<bool> isStudent(String userId) async {
    try {
      final profile = await getProfile(userId);
      return profile?['is_student'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  // 학생 목록 조회
  Future<List<Map<String, dynamic>>> getStudents(String proId) async {
    final response = await client
        .from('lesson_students')
        .select()
        .eq('pro_id', proId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  // 스케줄 조회
  Future<List<Map<String, dynamic>>> getSchedules({
    required String proId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await client
        .from('lesson_schedules')
        .select()
        .eq('pro_id', proId)
        .gte('lesson_date', startDate.toIso8601String())
        .lte('lesson_date', endDate.toIso8601String())
        .order('lesson_date')
        .order('lesson_time');
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  // 패키지 목록 조회
  Future<List<Map<String, dynamic>>> getPackages(String proId) async {
    final response = await client
        .from('lesson_packages')
        .select()
        .eq('pro_id', proId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  // 이미지 업로드
  Future<String> uploadImage({
    required String bucket,
    required String path,
    required List<int> bytes,
  }) async {
    await client.storage.from(bucket).uploadBinary(path, Uint8List.fromList(bytes));
    
    final url = client.storage.from(bucket).getPublicUrl(path);
    return url;
  }
  
  // 실시간 구독
  RealtimeChannel subscribeToTable({
    required String table,
    required void Function(dynamic payload) onInsert,
    required void Function(dynamic payload) onUpdate,
    required void Function(dynamic payload) onDelete,
  }) {
    return client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: (payload) => onInsert(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: (payload) => onUpdate(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: (payload) => onDelete(payload),
        )
        .subscribe();
  }
}