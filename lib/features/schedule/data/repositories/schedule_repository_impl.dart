import '../../../../core/constants/database_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/schedule_entity.dart';
import '../models/schedule_model.dart';

class ScheduleRepositoryImpl {
  final SupabaseService _supabaseService;

  ScheduleRepositoryImpl(this._supabaseService);

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

  Future<List<ScheduleEntity>> getSchedules({
    required String proId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _verifyProAccess(proId);
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
      return [];
    }
  }

  /// 학생용: student user_id 기반 스케줄 조회
  Future<List<ScheduleEntity>> getStudentSchedules({
    required String studentUserId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .select('*, lesson_students!inner(student_name, user_id)')
          .eq('lesson_students.user_id', studentUserId)
          .gte(DatabaseConstants.scheduleLessonDate, startDate.toIso8601String().split('T').first)
          .lte(DatabaseConstants.scheduleLessonDate, endDate.toIso8601String().split('T').first)
          .order(DatabaseConstants.scheduleLessonDate)
          .order(DatabaseConstants.scheduleLessonTime);

      final list = List<Map<String, dynamic>>.from(response);
      return list.map((json) => ScheduleModel.fromJson(json).toEntity()).toList();
    } catch (e) {
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
    String? recurringGroupId,
  }) async {
    _verifyProAccess(proId);
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
        if (recurringGroupId != null) 'recurring_group_id': recurringGroupId,
      };

      data.removeWhere((key, value) => value == null);

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .insert(data)
          .select('*, lesson_students(student_name)')
          .single();

      return ScheduleModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('스케줄 등록 실패');
    }
  }

  static const _allowedScheduleUpdateFields = <String>{
    'student_id',
    'package_id',
    'lesson_date',
    'lesson_time',
    'duration_minutes',
    'status',
    'location',
    'lesson_type',
    'memo',
    'recurring_group_id',
    'cancelled_by',
    'cancel_reason',
  };

  Future<ScheduleEntity> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    try {
      final filtered = <String, dynamic>{
        for (final entry in data.entries)
          if (_allowedScheduleUpdateFields.contains(entry.key)) entry.key: entry.value,
      };
      filtered['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .update(filtered)
          .eq(DatabaseConstants.scheduleId, scheduleId)
          .eq(DatabaseConstants.scheduleProId, _currentUserId)
          .select('*, lesson_students(student_name)')
          .single();

      return ScheduleModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('스케줄 수정 실패');
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
          .eq(DatabaseConstants.scheduleId, scheduleId)
          .eq(DatabaseConstants.scheduleProId, _currentUserId);
    } catch (e) {
      throw Exception('스케줄 삭제 실패');
    }
  }

  Future<int> deleteByRecurringGroup(String recurringGroupId) async {
    try {
      final response = await _supabaseService.client
          .from(DatabaseConstants.lessonSchedules)
          .delete()
          .eq('recurring_group_id', recurringGroupId)
          .eq('status', 'scheduled')
          .eq(DatabaseConstants.scheduleProId, _currentUserId)
          .select();
      return List.from(response).length;
    } catch (e) {
      throw Exception('반복 레슨 일괄 삭제 실패');
    }
  }

  Future<int> getWeeklyLessonCount(String proId) async {
    _verifyProAccess(proId);
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
