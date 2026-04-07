import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../data/models/schedule_model.dart';
import '../../domain/entities/schedule_entity.dart';

part 'schedule_provider.g.dart';

@riverpod
ScheduleRepositoryImpl scheduleRepository(Ref ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return ScheduleRepositoryImpl(supabaseService);
}

/// 선택된 날짜
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void update(DateTime date) => state = date;
}

/// 선택된 주의 시작일 (월요일)
@riverpod
DateTime selectedWeekStart(Ref ref) {
  final date = ref.watch(selectedDateProvider);
  return date.subtract(Duration(days: date.weekday - 1));
}

/// 주간 스케줄
@riverpod
Future<List<ScheduleEntity>> weeklySchedules(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(scheduleRepositoryProvider);
  final weekStart = ref.watch(selectedWeekStartProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));
  return repo.getSchedules(proId: user.id, startDate: weekStart, endDate: weekEnd);
}

/// 선택된 날짜의 스케줄
@riverpod
AsyncValue<List<ScheduleEntity>> dailySchedules(Ref ref) {
  final schedulesAsync = ref.watch(weeklySchedulesProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return schedulesAsync.whenData((schedules) {
    return schedules.where((s) {
      return s.lessonDate.year == selectedDate.year &&
          s.lessonDate.month == selectedDate.month &&
          s.lessonDate.day == selectedDate.day;
    }).toList();
  });
}

/// 오늘의 스케줄
@riverpod
Future<List<ScheduleEntity>> todaySchedules(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(scheduleRepositoryProvider);
  return repo.getTodaySchedules(user.id);
}

/// 이번 주 레슨 횟수
@riverpod
Future<int> weeklyLessonCount(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final repo = ref.watch(scheduleRepositoryProvider);
  return repo.getWeeklyLessonCount(user.id);
}

/// 학생이 취소한 레슨 알림 (최근 7일, 프로 대시보드용)
final studentCancelledLessonsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final weekAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();
  final response = await Supabase.instance.client
      .from('lesson_schedules')
      .select('*, lesson_students(student_name)')
      .eq('pro_id', user.id)
      .eq('status', 'cancelled')
      .eq('cancelled_by', 'student')
      .gte('updated_at', weekAgo)
      .order('updated_at', ascending: false)
      .limit(10);

  return List<Map<String, dynamic>>.from(response);
});

// ──────────────────────────────────────────────
// 학생용 스케줄 프로바이더 (student_id 기반 조회)
// ──────────────────────────────────────────────

/// 현재 학생 사용자의 lesson_students 레코드 ID 목록
final studentRecordIdsProvider = FutureProvider<List<String>>((ref) async {
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

/// 학생용 주간 스케줄
final studentWeeklySchedulesProvider = FutureProvider<List<ScheduleEntity>>((ref) async {
  final studentIds = await ref.watch(studentRecordIdsProvider.future);
  if (studentIds.isEmpty) return [];

  final weekStart = ref.watch(selectedWeekStartProvider);
  final weekEnd = weekStart.add(const Duration(days: 7));

  final response = await Supabase.instance.client
      .from('lesson_schedules')
      .select('*')
      .inFilter('student_id', studentIds)
      .gte('lesson_date', weekStart.toIso8601String().split('T').first)
      .lte('lesson_date', weekEnd.toIso8601String().split('T').first)
      .order('lesson_date')
      .order('lesson_time');

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
    final entity = ScheduleModel.fromJson(json).toEntity();
    final proName = proNames[json['pro_id'] as String] ?? '레슨프로';
    return entity.copyWith(studentName: proName);
  }).toList();
});

/// 학생의 다음 예정 레슨 날짜
final studentNextLessonDateProvider = FutureProvider<DateTime?>((ref) async {
  final studentIds = await ref.watch(studentRecordIdsProvider.future);
  if (studentIds.isEmpty) return null;

  final today = DateTime.now().toIso8601String().split('T').first;
  final response = await Supabase.instance.client
      .from('lesson_schedules')
      .select('lesson_date')
      .inFilter('student_id', studentIds)
      .gte('lesson_date', today)
      .order('lesson_date', ascending: true)
      .limit(1);

  final list = List<Map<String, dynamic>>.from(response);
  if (list.isEmpty) return null;
  return DateTime.parse(list.first['lesson_date'] as String);
});

/// 학생의 다가오는 레슨 목록 (오늘 이후, 최대 10건)
final studentUpcomingSchedulesProvider = FutureProvider<List<ScheduleEntity>>((ref) async {
  final studentIds = await ref.watch(studentRecordIdsProvider.future);
  if (studentIds.isEmpty) return [];

  final today = DateTime.now().toIso8601String().split('T').first;
  final response = await Supabase.instance.client
      .from('lesson_schedules')
      .select('*')
      .inFilter('student_id', studentIds)
      .eq('status', 'scheduled')
      .gte('lesson_date', today)
      .order('lesson_date', ascending: true)
      .order('lesson_time', ascending: true)
      .limit(10);

  final list = List<Map<String, dynamic>>.from(response);
  if (list.isEmpty) return [];

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
    final entity = ScheduleModel.fromJson(json).toEntity();
    final proName = proNames[json['pro_id'] as String] ?? '레슨프로';
    return entity.copyWith(studentName: proName);
  }).toList();
});

/// 학생용 선택된 날짜의 스케줄
final studentDailySchedulesProvider = Provider<AsyncValue<List<ScheduleEntity>>>((ref) {
  final schedulesAsync = ref.watch(studentWeeklySchedulesProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return schedulesAsync.whenData((schedules) {
    return schedules.where((s) {
      return s.lessonDate.year == selectedDate.year &&
          s.lessonDate.month == selectedDate.month &&
          s.lessonDate.day == selectedDate.day;
    }).toList();
  });
});
