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

/// 전체 학생 목록 (비활성 포함) 프로바이더
@riverpod
Future<List<StudentEntity>> allStudents(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(studentRepositoryProvider);
  return repo.getStudents(user.id, activeOnly: false);
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

/// 학생 상태 필터 ('all', 'active', 'inactive')
@riverpod
class StudentStatusFilter extends _$StudentStatusFilter {
  @override
  String build() => 'active';

  void update(String filter) => state = filter;
}

/// 학생 그룹 필터
@riverpod
class StudentGroupFilter extends _$StudentGroupFilter {
  @override
  String? build() => null; // null = 전체

  void update(String? group) => state = group;
}

/// 가족 구성원 프로바이더
@riverpod
Future<List<StudentEntity>> familyMembers(Ref ref, String familyGroupId) async {
  final repo = ref.watch(studentRepositoryProvider);
  return repo.getFamilyMembers(familyGroupId);
}

/// 필터된 학생 목록
@riverpod
AsyncValue<List<StudentEntity>> filteredStudents(Ref ref) {
  final statusFilter = ref.watch(studentStatusFilterProvider);
  final studentsAsync = statusFilter == 'active'
      ? ref.watch(studentsProvider)
      : ref.watch(allStudentsProvider);
  final query = ref.watch(studentSearchQueryProvider).toLowerCase();

  final groupFilter = ref.watch(studentGroupFilterProvider);

  return studentsAsync.whenData((students) {
    var filtered = students.where((s) {
      // 상태 필터
      if (statusFilter == 'active' && !s.isActive) return false;
      if (statusFilter == 'inactive' && s.isActive) return false;
      // 그룹 필터
      if (groupFilter != null && s.groupName != groupFilter) return false;
      return true;
    }).toList();

    // 검색 필터
    if (query.isNotEmpty) {
      filtered = filtered.where((s) {
        return s.studentName.toLowerCase().contains(query) ||
            (s.studentPhone?.contains(query) ?? false) ||
            (s.studentEmail?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 가나다순 정렬
    filtered.sort((a, b) => a.studentName.compareTo(b.studentName));
    return filtered;
  });
}
