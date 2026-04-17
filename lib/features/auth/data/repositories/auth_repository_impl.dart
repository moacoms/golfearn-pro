import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepositoryImpl(this._supabaseService);

  @override
  UserEntity? get currentUser {
    final user = _supabaseService.currentUser;
    if (user == null) return null;
    
    // 프로필 정보를 동기화해서 가져와야 하지만, 여기서는 기본 정보만
    return UserEntity(
      id: user.id,
      email: user.email!,
      fullName: user.userMetadata?['full_name'],
      phoneNumber: user.userMetadata?['phone_number'],
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _supabaseService.authStateChanges.asyncMap((authState) async {
      final user = authState.session?.user;
      if (user == null) return null;

      try {
        // 프로필 정보 조회
        final profile = await _supabaseService.getProfile(user.id);
        if (profile != null) {
          final entity = UserModel.fromJson(profile).toEntity();
          // profiles 테이블에 email이 없으므로 auth에서 보완
          return entity.copyWith(email: user.email ?? entity.email);
        }
      } catch (e) {
      }

      // 프로필이 없으면 auth 메타데이터에서 기본 정보 반환
      return UserEntity(
        id: user.id,
        email: user.email!,
        fullName: user.userMetadata?['full_name'] as String?,
        phoneNumber: user.userMetadata?['phone_number'] as String?,
      );
    });
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('로그인에 실패했습니다.');
      }

      // 프로필 정보 조회
      try {
        final profile = await _supabaseService.getProfile(response.user!.id);
        if (profile != null) {
          return UserModel.fromJson(profile).toEntity();
        }
      } catch (e) {
      }

      // 프로필이 없으면 기본 정보만 반환
      return UserEntity(
        id: response.user!.id,
        email: response.user!.email!,
      );
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.message));
    } catch (e, stackTrace) {
      throw Exception('로그인에 실패했습니다.');
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
    bool isLessonPro = false,
  }) async {
    // 신규 가입은 항상 학생으로 시작. 프로 전환은 별도 registerAsLessonPro()로만 가능
    // (클라이언트가 임의로 is_lesson_pro=true 설정하는 것을 차단)
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
        },
      );

      if (response.user == null) {
        throw Exception('회원가입에 실패했습니다.');
      }

      // 이미 등록된 이메일인지 확인
      // Supabase는 이미 존재하는 이메일에 대해:
      // - identities가 빈 배열 → 이미 가입된 이메일
      // - session이 null → 이메일 인증 필요
      final identities = response.user!.identities;
      if (identities == null || identities.isEmpty) {
        // 이미 가입된 이메일 — 혹시 세션이 생겼다면 로그아웃
        if (response.session != null) {
          await _supabaseService.signOut();
        }
        throw AuthException('User already registered');
      }

      if (response.session == null) {
        throw Exception('이메일 인증이 필요합니다. 이메일을 확인해주세요.');
      }

      // 2단계: 프로필 생성/업데이트 - upsert로 트리거 충돌 방지
      try {
        // 트리거가 프로필을 생성할 시간을 확보
        await Future.delayed(const Duration(milliseconds: 500));

        // upsert: 트리거가 이미 만들었으면 update, 안 만들었으면 insert
        // 보안: is_lesson_pro/is_student는 서버 트리거가 결정 (클라이언트 신뢰 X)
        final profile = await _supabaseService.client
            .from('profiles')
            .upsert({
              'id': response.user!.id,
              'full_name': fullName,
              'pro_phone': phoneNumber,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();
        final entity = UserModel.fromJson(profile).toEntity();
        // 프로 전환 요청 시 별도 플로우로 승격
        if (isLessonPro) {
          return await registerAsLessonPro(
            fullName: fullName ?? '',
            phoneNumber: phoneNumber ?? '',
          );
        }
        return entity.copyWith(email: email);
      } catch (e) {
        // 프로필 처리 실패해도 기본 정보로 진행 — 항상 학생으로 시작
        return UserEntity(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          isLessonPro: false,
          isStudent: true,
        );
      }
    } on AuthException catch (e) {
      // 422 = 이미 등록된 이메일 또는 유효하지 않은 입력
      if (e.statusCode == '422' ||
          e.message.contains('already') ||
          e.message.contains('registered')) {
        throw Exception('이미 가입된 이메일입니다.');
      }
      throw Exception(_getAuthErrorMessage(e.message));
    } catch (e) {
      if (e.toString().contains('already') || e.toString().contains('이미 가입된')) {
        rethrow;
      }
      if (e.toString().contains('Database error')) {
        throw Exception('잠시 후 다시 시도해주세요.');
      }
      throw Exception('회원가입에 실패했습니다.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<UserEntity> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? sportType,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['pro_phone'] = phoneNumber;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (extraFields != null) updateData.addAll(extraFields);

      if (updateData.isEmpty) {
        throw Exception('업데이트할 정보가 없습니다.');
      }

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final profile = await _supabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(profile).toEntity();
    } catch (e) {
      throw Exception('프로필 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<UserEntity> registerAsLessonPro({
    required String fullName,
    required String phoneNumber,
    String? bio,
    List<String>? certifications,
    int? experience,
    String? sportType,
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // RLS가 is_lesson_pro 자가 update를 차단하므로 보안 RPC 경유
      final profile = await _supabaseService.client.rpc(
        'promote_to_lesson_pro',
        params: {
          'p_full_name': fullName,
          'p_phone': phoneNumber,
          'p_introduction': bio,
          'p_experience_years': experience,
        },
      );

      if (profile == null) {
        throw Exception('레슨프로 등록 응답이 비어있습니다.');
      }

      return UserModel.fromJson(
        Map<String, dynamic>.from(profile as Map),
      ).toEntity();
    } catch (e) {
      throw Exception('레슨프로 등록 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.message));
    } catch (e) {
      throw Exception('이메일 발송에 실패했습니다.');
    }
  }

  @override
  Future<void> signInWithKakao() async {
    try {
      // 웹: 현재 오리진으로 복귀 (localhost:8080 또는 vercel.app)
      //      Supabase Site URL이 다른 프로젝트(golfearn.com) 공유 중이므로
      //      redirectTo를 명시하지 않으면 엉뚱한 곳으로 감.
      // 모바일: 커스텀 스킴 (supabase_flutter가 Custom Tabs/SFSafariVC 처리)
      final redirectTo = kIsWeb
          ? '${Uri.base.origin}/'
          : 'io.supabase.golfearn://login-callback';

      await _supabaseService.client.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: redirectTo,
      );
      // OAuth 리다이렉트 기반이므로 여기서는 세션이 아직 없음.
      // 콜백 후 authStateChanges stream이 세션을 방출함.
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.message));
    } catch (e) {
      throw Exception('카카오 로그인 중 오류가 발생했습니다.');
    }
  }

  String _getAuthErrorMessage(String errorMessage) {
    switch (errorMessage) {
      case 'Invalid login credentials':
        return '이메일 또는 비밀번호를 확인해주세요.';
      case 'Email not confirmed':
        return '이메일 인증을 완료해주세요.';
      case 'User already registered':
        return '이미 가입된 이메일입니다.';
      case 'Signup requires a valid password':
        return '비밀번호를 확인해주세요.';
      default:
        return errorMessage;
    }
  }
}