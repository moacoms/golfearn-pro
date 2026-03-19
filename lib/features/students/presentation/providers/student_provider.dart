import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/entities/student_entity.dart';

part 'student_provider.g.dart';

/// StudentRepository 프로바이더
@riverpod
StudentRepositoryImpl studentRepository(Ref ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return StudentRepositoryImpl(supabaseService);
}

/// 학생 목록 프로바이더
@riverpod
Future<List<StudentEntity>> students(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(studentRepositoryProvider);
  return repo.getStudents(user.id);
}

/// 학생 상세 프로바이더
@riverpod
Future<StudentEntity> studentDetail(Ref ref, String studentId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return repo.getStudent(studentId);
}

/// 학생 수 프로바이더
@riverpod
Future<int> studentCount(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final repo = ref.watch(studentRepositoryProvider);
  return repo.getStudentCount(user.id);
}

/// 학생 검색 필터
@riverpod
class StudentSearchQuery extends _$StudentSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

/// 필터된 학생 목록
@riverpod
AsyncValue<List<StudentEntity>> filteredStudents(Ref ref) {
  final studentsAsync = ref.watch(studentsProvider);
  final query = ref.watch(studentSearchQueryProvider).toLowerCase();

  return studentsAsync.whenData((students) {
    if (query.isEmpty) return students;
    return students.where((s) {
      return s.studentName.toLowerCase().contains(query) ||
          (s.studentPhone?.contains(query) ?? false) ||
          (s.studentEmail?.toLowerCase().contains(query) ?? false);
    }).toList();
  });
}
