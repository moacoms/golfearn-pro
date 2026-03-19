import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/schedule_repository_impl.dart';
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
