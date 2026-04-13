import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/lesson_note_entity.dart';
import '../models/lesson_note_model.dart';

class LessonNoteRepositoryImpl {
  final SupabaseService _supabaseService;

  LessonNoteRepositoryImpl(this._supabaseService);

  String get _currentUserId {
    final uid = _supabaseService.currentUser?.id;
    if (uid == null) throw Exception('인증이 필요합니다.');
    return uid;
  }

  void _verifyProAccess(String proId) {
    if (proId != _currentUserId) {
      throw Exception('접근 권한이 없습니다.');
    }
  }

  Future<List<LessonNoteEntity>> getLessonNotes(String proId) async {
    _verifyProAccess(proId);
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .select('*, lesson_students(student_name)')
          .eq('pro_id', proId)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => LessonNoteModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  /// 학생용: student_id 기반 노트 조회 (프로 인가 불필요)
  Future<List<LessonNoteEntity>> getStudentNotesByStudentUserId(String studentUserId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .select('*, lesson_students!inner(student_name, user_id)')
          .eq('lesson_students.user_id', studentUserId)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => LessonNoteModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<LessonNoteEntity>> getStudentNotes(String proId, String studentId) async {
    _verifyProAccess(proId);
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .select('*, lesson_students(student_name)')
          .eq('pro_id', proId)
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => LessonNoteModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw Exception('학생 레슨 노트 조회 실패');
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
    _verifyProAccess(proId);
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

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .insert(data)
          .select('*')
          .single();

      return LessonNoteModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('레슨 노트 작성 실패');
    }
  }

  Future<LessonNoteEntity> updateLessonNote(String noteId, Map<String, dynamic> data) async {
    try {
      data.remove('pro_id');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .update(data)
          .eq('id', noteId)
          .eq('pro_id', _currentUserId)
          .select('*')
          .single();

      return LessonNoteModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('레슨 노트 수정 실패');
    }
  }

  Future<void> deleteLessonNote(String noteId) async {
    try {
      await _supabaseService.client
          .from(DatabaseConstants.lessonNotes)
          .delete()
          .eq('id', noteId)
          .eq('pro_id', _currentUserId);
    } catch (e) {
      throw Exception('레슨 노트 삭제 실패');
    }
  }
}
