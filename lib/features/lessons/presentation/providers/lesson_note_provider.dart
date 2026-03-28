import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/lesson_note_repository_impl.dart';
import '../../data/models/lesson_note_model.dart';
import '../../domain/entities/lesson_note_entity.dart';

part 'lesson_note_provider.g.dart';

@riverpod
LessonNoteRepositoryImpl lessonNoteRepository(Ref ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return LessonNoteRepositoryImpl(supabaseService);
}

/// 전체 레슨 노트 목록
@riverpod
Future<List<LessonNoteEntity>> lessonNotes(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(lessonNoteRepositoryProvider);
  return repo.getLessonNotes(user.id);
}

/// 특정 학생의 레슨 노트
@riverpod
Future<List<LessonNoteEntity>> studentNotes(Ref ref, String studentId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(lessonNoteRepositoryProvider);
  return repo.getStudentNotes(user.id, studentId);
}

// ──────────────────────────────────────────────
// 학생용 레슨 노트 프로바이더 (student_id 기반 조회)
// ──────────────────────────────────────────────

/// 현재 학생 사용자의 lesson_students 레코드 ID 목록
final _myStudentRecordIdsForNotesProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final response = await Supabase.instance.client
      .from('lesson_students')
      .select('id')
      .eq('user_id', user.id)
      .eq('is_active', true);

  final list = List<Map<String, dynamic>>.from(response);
  return list.map((e) => e['id'] as String).toList();
});

/// 학생용: 나에 대한 레슨 노트 목록 (프로가 작성한 것)
final studentLessonNotesProvider = FutureProvider<List<LessonNoteEntity>>((ref) async {
  final studentIds = await ref.watch(_myStudentRecordIdsForNotesProvider.future);
  if (studentIds.isEmpty) return [];

  final response = await Supabase.instance.client
      .from('lesson_notes')
      .select('*')
      .inFilter('student_id', studentIds)
      .order('created_at', ascending: false);

  final list = List<Map<String, dynamic>>.from(response);
  if (list.isEmpty) return [];

  // 프로 ID 목록을 모아서 한 번에 이름 조회
  final proIds = list.map((e) => e['pro_id'] as String).toSet().toList();
  final profilesResp = await Supabase.instance.client
      .from('profiles')
      .select('id, full_name')
      .inFilter('id', proIds);
  final proNames = <String, String>{};
  for (final p in List<Map<String, dynamic>>.from(profilesResp)) {
    proNames[p['id'] as String] = (p['full_name'] as String?) ?? '레슨프로';
  }

  return list.map((json) {
    final entity = LessonNoteModel.fromJson(json).toEntity();
    final proName = proNames[json['pro_id'] as String] ?? '레슨프로';
    return entity.copyWith(studentName: proName);
  }).toList();
});
