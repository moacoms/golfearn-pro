import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// 현재 로그인된 사용자
  UserEntity? get currentUser;
  
  /// 인증 상태 스트림
  Stream<UserEntity?> get authStateChanges;
  
  /// 이메일/비밀번호로 로그인
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// 이메일/비밀번호로 회원가입
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
    bool isLessonPro = false,
  });
  
  /// 로그아웃
  Future<void> signOut();
  
  /// 프로필 업데이트
  Future<UserEntity> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? sportType,
    Map<String, dynamic>? extraFields,
  });

  /// 레슨프로 등록
  Future<UserEntity> registerAsLessonPro({
    required String fullName,
    required String phoneNumber,
    String? bio,
    List<String>? certifications,
    int? experience,
    String? sportType,
  });

  /// 비밀번호 재설정 이메일 발송
  Future<void> resetPassword({required String email});

  /// 카카오 OAuth 로그인 (웹 기반 flow, supabase 네이티브 provider)
  /// 성공 시 authStateChanges stream이 세션을 방출함 → 호출자는 즉시 리턴값 사용 X
  Future<void> signInWithKakao();
}