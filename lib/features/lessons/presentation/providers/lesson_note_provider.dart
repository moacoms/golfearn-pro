import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/lesson_note_repository_impl.dart';
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
