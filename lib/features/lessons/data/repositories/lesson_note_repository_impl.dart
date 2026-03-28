import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/lesson_note_entity.dart';
import '../models/lesson_note_model.dart';

class LessonNoteRepositoryImpl {
  final SupabaseService _supabaseService;

  LessonNoteRepositoryImpl(this._supabaseService);

  Future<List<LessonNoteEntity>> getLessonNotes(String proId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .select('*')
          .eq('pro_id', proId)
          .order('lesson_date', ascending: false)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => LessonNoteModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      // 테이블이 없거나 조회 실패 시 빈 리스트 반환
      print('레슨 노트 조회 실패: $e');
      return [];
    }
  }

  Future<List<LessonNoteEntity>> getStudentNotes(String proId, String studentId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .select('*')
          .eq('pro_id', proId)
          .eq('student_id', studentId)
          .order('lesson_date', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => LessonNoteModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw Exception('학생 레슨 노트 조회 실패: $e');
    }
  }

  Future<LessonNoteEntity> createLessonNote({
    required String proId,
    required String studentId,
    String? scheduleId,
    required DateTime lessonDate,
    String? title,
    String? content,
    String? improvement,
    String? homework,
  }) async {
    try {
      final data = {
        'pro_id': proId,
        'student_id': studentId,
        if (scheduleId != null) 'schedule_id': scheduleId,
        'lesson_date': lessonDate.toIso8601String().split('T').first,
        'title': title,
        'content': content,
        'improvement': improvement,
        'homework': homework,
      };

      data.removeWhere((key, value) => value == null);

      print('레슨 노트 저장 데이터: $data');

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .insert(data)
          .select('*')
          .single();

      return LessonNoteModel.fromJson(response).toEntity();
    } catch (e) {
      print('레슨 노트 작성 실패 상세: $e');
      throw Exception('레슨 노트 작성 실패: $e');
    }
  }

  Future<LessonNoteEntity> updateLessonNote(String noteId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .update(data)
          .eq('id', noteId)
          .select('*')
          .single();

      return LessonNoteModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('레슨 노트 수정 실패: $e');
    }
  }

  Future<void> deleteLessonNote(String noteId) async {
    try {
      await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .delete()
          .eq('id', noteId);
    } catch (e) {
      throw Exception('레슨 노트 삭제 실패: $e');
    }
  }
}
