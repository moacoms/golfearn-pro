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
        if (profile == null) {
          return UserEntity(
            id: user.id,
            email: user.email!,
          );
        }

        return UserModel.fromJson(profile).toEntity();
      } catch (e) {
        // 프로필 조회 실패 시 기본 정보만 반환
        return UserEntity(
          id: user.id,
          email: user.email!,
        );
      }
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
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
        },
      );

      if (response.user == null) {
        throw Exception('회원가입에 실패했습니다.');
      }

      // 프로필 생성
      final profileData = {
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'is_lesson_pro': false,
        'is_student': true,
        'is_admin': false,
      };

      final profile = await _supabaseService.client
          .from('profiles')
          .insert(profileData)
          .select()
          .single();

      return UserModel.fromJson(profile).toEntity();
    } on AuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.message));
    } catch (e) {
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
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final updateData = <String, dynamic>{};
      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

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
  }) async {
    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final updateData = {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'is_lesson_pro': true,
        'is_student': false,
        'bio': bio,
        'certifications': certifications,
        'experience_years': experience,
        'updated_at': DateTime.now().toIso8601String(),
      };

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