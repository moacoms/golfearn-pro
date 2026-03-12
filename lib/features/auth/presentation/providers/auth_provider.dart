import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_controller.dart';

part 'auth_provider.g.dart';

/// AuthRepository 프로바이더
@riverpod
AuthRepository authRepository(Ref ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthRepositoryImpl(supabaseService);
}

/// 현재 사용자 프로바이더
@riverpod
UserEntity? currentUser(Ref ref) {
  // authController의 상태를 감시하여 user 정보를 반환
  final authState = ref.watch(authControllerProvider);
  return authState.user;
}

/// 인증 상태 스트림 프로바이더
@riverpod
Stream<UserEntity?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// 로그인 상태 프로바이더 (boolean)
@riverpod
bool isAuthenticated(Ref ref) {
  return ref.watch(currentUserProvider) != null;
}

/// 레슨프로 여부 프로바이더
@riverpod
bool isLessonPro(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isLessonPro ?? false;
}

/// 학생 여부 프로바이더
@riverpod
bool isStudent(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isStudent ?? false;
}

/// 관리자 여부 프로바이더
@riverpod
bool isAdmin(Ref ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
}