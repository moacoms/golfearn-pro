import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/package_repository_impl.dart';
import '../../domain/entities/package_entity.dart';

part 'package_provider.g.dart';

@riverpod
PackageRepositoryImpl packageRepository(Ref ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return PackageRepositoryImpl(supabaseService);
}

/// 전체 패키지 목록
@riverpod
Future<List<PackageEntity>> packages(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(packageRepositoryProvider);
  return repo.getPackages(user.id);
}

/// 특정 학생의 활성 패키지
@riverpod
Future<List<PackageEntity>> studentActivePackages(Ref ref, String studentId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(packageRepositoryProvider);
  return repo.getActivePackages(user.id, studentId);
}
