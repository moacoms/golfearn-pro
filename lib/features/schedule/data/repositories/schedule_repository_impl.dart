import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/schedule_entity.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl {
  final SupabaseService _supabaseService;

  ScheduleRepositoryImpl(this._supabaseService);

  Future<List<ScheduleEntity>> getSchedules({
    required String proId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .select('*, lesson_students(student_name)')
          .eq(DatabaseConstants.scheduleProId, proId)
          .gte(DatabaseConstants.scheduleLessonDate, startDate.toIso8601String().split('T').first)
          .lte(DatabaseConstants.scheduleLessonDate, endDate.toIso8601String().split('T').first)
          .order(DatabaseConstants.scheduleLessonDate)
          .order(DatabaseConstants.scheduleLessonTime);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => ScheduleModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      print('스케줄 조회 실패: $e');
      return [];
    }
  }

  Future<List<ScheduleEntity>> getTodaySchedules(String proId) async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 1));
    return getSchedules(proId: proId, startDate: start, endDate: end);
  }

  Future<ScheduleEntity> createSchedule({
    required String proId,
    required String studentId,
    String? packageId,
    required DateTime lessonDate,
    required String lessonTime,
    int durationMinutes = 60,
    String? location,
    String? lessonType,
    String? memo,
  }) async {
    try {
      final data = {
        'pro_id': proId,
        'student_id': studentId,
        if (packageId != null) 'package_id': packageId,
        'lesson_date': lessonDate.toIso8601String().split('T').first,
        'lesson_time': lessonTime,
        'duration_minutes': durationMinutes,
        'status': DatabaseConstants.scheduleStatusScheduled,
        'location': location,
        'lesson_type': lessonType ?? DatabaseConstants.lessonTypeRegular,
        'memo': memo,
      };

      data.removeWhere((key, value) => value == null);

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .insert(data)
          .select('*, lesson_students(student_name)')
          .single();

      return ScheduleModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('스케줄 등록 실패: $e');
    }
  }

  Future<ScheduleEntity> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = DateTime.now().toIso8601String();
      data.removeWhere((key, value) => value == null && key != 'updated_at');

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .update(data)
          .eq(DatabaseConstants.scheduleId, scheduleId)
          .select('*, lesson_students(student_name)')
          .single();

      return ScheduleModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('스케줄 수정 실패: $e');
    }
  }

  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await updateSchedule(scheduleId, {'status': status});
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .delete()
          .eq(DatabaseConstants.scheduleId, scheduleId);
    } catch (e) {
      throw Exception('스케줄 삭제 실패: $e');
    }
  }

  Future<int> getWeeklyLessonCount(String proId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .select()
          .eq(DatabaseConstants.scheduleProId, proId)
          .gte(DatabaseConstants.scheduleLessonDate, weekStart.toIso8601String().split('T').first)
          .lt(DatabaseConstants.scheduleLessonDate, weekEnd.toIso8601String().split('T').first);

      return List.from(response).length;
    } catch (e) {
      return 0;
    }
  }
}
