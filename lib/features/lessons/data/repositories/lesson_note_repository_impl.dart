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
          .select('*, lesson_students!inner(student_name)')
          .eq('pro_id', proId)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => LessonNoteModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      print('레슨 노트 조회 실패: $e');
      return [];
    }
  }

  Future<List<LessonNoteEntity>> getStudentNotes(String proId, String studentId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .select('*, lesson_students!inner(student_name)')
          .eq('pro_id', proId)
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

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
    String? manualNote,
    String? homework,
    String? nextFocus,
    List<String>? keyPoints,
    List<String>? improvements,
    int? practiceTimeMinutes,
  }) async {
    try {
      final data = <String, dynamic>{
        'pro_id': proId,
        'student_id': studentId,
        if (scheduleId != null) 'schedule_id': scheduleId,
        if (manualNote != null) 'manual_note': manualNote,
        if (homework != null) 'homework': homework,
        if (nextFocus != null) 'next_focus': nextFocus,
        if (keyPoints != null) 'key_points': keyPoints,
        if (improvements != null) 'improvements': improvements,
        if (practiceTimeMinutes != null) 'practice_time_minutes': practiceTimeMinutes,
      };

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
