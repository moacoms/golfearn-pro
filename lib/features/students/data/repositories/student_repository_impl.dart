import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/student_entity.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl {
  final SupabaseService _supabaseService;

  StudentRepositoryImpl(this._supabaseService);

  Future<List<StudentEntity>> getStudents(String proId, {bool activeOnly = true}) async {
    try {
      var query = _supabaseService.client
          .from(DatabaseConstants.lessonStudents)
          .select()
          .eq(DatabaseConstants.studentProId, proId);

      if (activeOnly) {
        query = query.eq(DatabaseConstants.studentIsActive, true);
      }

      final response = await query.order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => StudentModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw Exception('학생 목록 조회 실패: $e');
    }
  }

  Future<StudentEntity> getStudent(String studentId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonStudents)
          .select()
          .eq(DatabaseConstants.studentId, studentId)
          .single();
      return StudentModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('학생 조회 실패: $e');
    }
  }

  Future<StudentEntity> createStudent({
    required String proId,
    required String studentName,
    String? studentPhone,
    String? studentEmail,
    String? studentMemo,
    String? currentLevel,
    String? goal,
    DateTime? birthDate,
    String? gender,
    DateTime? startedGolfAt,
    int? averageScore,
    String? groupName,
  }) async {
    try {
      final data = {
        'pro_id': proId,
        'student_name': studentName,
        'student_phone': studentPhone,
        'student_email': studentEmail,
        'student_memo': studentMemo,
        'current_level': currentLevel,
        'goal': goal,
        'birth_date': birthDate?.toIso8601String().split('T').first,
        'gender': gender,
        'started_golf_at': startedGolfAt?.toIso8601String().split('T').first,
        'average_score': averageScore,
        'group_name': groupName,
        'is_active': true,
        'total_lesson_count': 0,
      };

      // null 값 제거
      data.removeWhere((key, value) => value == null);

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonStudents)
          .insert(data)
          .select()
          .single();
      return StudentModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('학생 등록 실패: $e');
    }
  }

  Future<StudentEntity> updateStudent(String studentId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonStudents)
          .update(data)
          .eq(DatabaseConstants.studentId, studentId)
          .select()
          .single();
      return StudentModel.fromJson(response).toEntity();
    } catch (e) {
      print('학생 수정 에러 - studentId: $studentId, data: $data, error: $e');
      throw Exception('학생 정보 수정 실패: $e');
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      // 소프트 삭제 (is_active = false)
      await _supabaseService.client
          .from(DatabaseConstants.lessonStudents)
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq(DatabaseConstants.studentId, studentId);
    } catch (e) {
      throw Exception('학생 삭제 실패: $e');
    }
  }

  Future<List<StudentEntity>> getFamilyMembers(String familyGroupId, {String? excludeStudentId}) async {
    try {
      var query = _supabaseService.client
          .from(DatabaseConstants.lessonStudents)
          .select()
          .eq('family_group_id', familyGroupId)
          .eq(DatabaseConstants.studentIsActive, true);

      final response = await query.order('student_name');
      final list = List<Map<String, dynamic>>.from(response);
      var result = list.map((json) => StudentModel.fromJson(json).toEntity()).toList();
      if (excludeStudentId != null) {
        result = result.where((s) => s.id != excludeStudentId).toList();
      }
      return result;
    } catch (e) {
      return [];
    }
  }

  Future<int> getStudentCount(String proId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonStudents)
          .select()
          .eq(DatabaseConstants.studentProId, proId)
          .eq(DatabaseConstants.studentIsActive, true);
      return List.from(response).length;
    } catch (e) {
      return 0;
    }
  }
}
