import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_provider.dart';

part 'auth_controller.g.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final UserEntity? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    UserEntity? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.user == user;
  }

  @override
  int get hashCode => Object.hash(isLoading, error, user);

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, error: $error, user: $user)';
  }
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    // 인증 상태 변화 감지
    ref.listen(authStateChangesProvider, (previous, next) {
      next.when(
        data: (user) => state = state.copyWith(user: user, error: null),
        loading: () => state = state.copyWith(isLoading: true),
        error: (error, _) => state = state.copyWith(error: error.toString()),
      );
    });

    return const AuthState();
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  /// 로그인
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('AuthController: 로그인 시작 - $email');
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('AuthController: 로그인 성공 - ${user.id}');
      state = state.copyWith(isLoading: false, user: user);
    } catch (e, stackTrace) {
      print('AuthController: 로그인 실패 - $e');
      print('AuthController: 스택 트레이스 - $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
    bool isLessonPro = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        isLessonPro: isLessonPro,
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      print('AuthController: 로그아웃 시작');
      await _authRepository.signOut();
      print('AuthController: 로그아웃 완료');
      state = state.copyWith(isLoading: false, user: null, error: null);
      // Provider를 무효화하여 캐시 클리어
      ref.invalidateSelf();
    } catch (e) {
      print('AuthController: 로그아웃 실패 - $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 프로필 업데이트
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? sportType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        sportType: sportType,
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 레슨프로 등록
  Future<void> registerAsLessonPro({
    required String fullName,
    required String phoneNumber,
    String? bio,
    List<String>? certifications,
    int? experience,
    String? sportType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.registerAsLessonPro(
        fullName: fullName,
        phoneNumber: phoneNumber,
        bio: bio,
        certifications: certifications,
        experience: experience,
        sportType: sportType,
      );
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.resetPassword(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }
}