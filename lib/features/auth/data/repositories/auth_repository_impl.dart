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
        print('프로필 조회 실패: $e');
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
      print('로그인 시도: $email');
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      print('로그인 응답: ${response.user?.id}');
      if (response.user == null) {
        throw Exception('로그인에 실패했습니다.');
      }

      // 프로필 정보 조회
      try {
        print('프로필 조회 시작: ${response.user!.id}');
        final profile = await _supabaseService.getProfile(response.user!.id);
        print('프로필 조회 결과: $profile');
        if (profile != null) {
          return UserModel.fromJson(profile).toEntity();
        }
      } catch (e) {
        print('프로필 조회 실패 상세: $e');
        print('스택 트레이스: ${StackTrace.current}');
      }

      // 프로필이 없으면 기본 정보만 반환
      print('기본 정보로 반환');
      return UserEntity(
        id: response.user!.id,
        email: response.user!.email!,
      );
    } on AuthException catch (e) {
      print('AuthException 발생: ${e.message}');
      print('AuthException 상태 코드: ${e.statusCode}');
      throw Exception(_getAuthErrorMessage(e.message));
    } catch (e, stackTrace) {
      print('로그인 중 오류 발생: $e');
      print('스택 트레이스: $stackTrace');
      throw Exception('로그인 중 오류가 발생했습니다: $e');
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
    try {
      // 트리거(handle_new_user)가 raw_user_meta_data에서 읽는 모든 필드를 전달
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'pro_phone': phoneNumber,
          'is_lesson_pro': isLessonPro,
          'is_student': !isLessonPro,
          'sport_type': 'golf',
        },
      );

      if (response.user == null) {
        throw Exception('회원가입에 실패했습니다.');
      }

      // 이미 등록된 이메일인지 확인
      // Supabase는 보안상 기존 이메일로 가입 시도 시 에러 대신 세션 없는 응답을 반환
      if (response.session == null) {
        final identities = response.user!.identities;
        if (identities == null || identities.isEmpty) {
          throw AuthException('User already registered');
        }
        // identities가 있으면 이메일 인증 대기 상태 (신규 가입)
        throw Exception('이메일 인증이 필요합니다. 이메일을 확인해주세요.');
      }

      // 프로필 upsert - 트리거가 이미 생성했을 수도 있으므로 upsert 사용
      try {
        final profile = await _supabaseService.client
            .from('profiles')
            .upsert({
              'id': response.user!.id,
              'full_name': fullName,
              'pro_phone': phoneNumber,
              'is_lesson_pro': isLessonPro,
              'is_student': !isLessonPro,
              'sport_type': 'golf',
              'updated_at': DateTime.now().toIso8601String(),
            }, onConflict: 'id')
            .select()
            .single();
        final entity = UserModel.fromJson(profile).toEntity();
        return entity.copyWith(email: email);
      } catch (e) {
        print('프로필 upsert 실패 (트리거가 처리했을 수 있음): $e');
        // 트리거가 이미 프로필을 생성한 경우 조회 시도
        try {
          final existingProfile = await _supabaseService.getProfile(response.user!.id);
          if (existingProfile != null) {
            final entity = UserModel.fromJson(existingProfile).toEntity();
            return entity.copyWith(email: email);
          }
        } catch (_) {}
        return UserEntity(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          isLessonPro: isLessonPro,
          isStudent: !isLessonPro,
        );
      }
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.message));
    } catch (e) {
      if (e.toString().contains('Database error')) {
        throw Exception('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
      }
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      print('AuthRepository: 로그아웃 시작');
      await _supabaseService.signOut();
      print('AuthRepository: 로그아웃 완료');
    } catch (e) {
      print('AuthRepository: 로그아웃 실패 - $e');
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<UserEntity> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? sportType,
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
      // sport_type은 DB 컬럼 추가 후 활성화
      // if (sportType != null) updateData['sport_type'] = sportType;

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

      final updateData = <String, dynamic>{
        'full_name': fullName,
        'pro_phone': phoneNumber,
        'is_lesson_pro': true,
        'is_student': false,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (bio != null) updateData['pro_introduction'] = bio;
      if (experience != null) updateData['pro_experience_years'] = experience;
      // sport_type은 DB 컬럼 추가 후 활성화
      // if (sportType != null) updateData['sport_type'] = sportType;

      final profile = await _supabaseService.client
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(profile).toEntity();
    } catch (e) {
      throw Exception('레슨프로 등록 중 오류가 발생했습니다: $e');
    }
  }

  String _getAuthErrorMessage(String errorMessage) {
    switch (errorMessage) {
      case 'Invalid login credentials':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'Email not confirmed':
        return '이메일 인증이 완료되지 않았습니다.';
      case 'User already registered':
        return '이미 가입된 이메일입니다.';
      case 'Signup requires a valid password':
        return '유효한 비밀번호를 입력해주세요.';
      default:
        return errorMessage;
    }
  }
}