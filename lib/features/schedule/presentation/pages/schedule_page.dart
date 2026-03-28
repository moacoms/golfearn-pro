import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/constants/sport_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../../packages/domain/entities/package_entity.dart';
import '../../../packages/presentation/providers/package_provider.dart';
import '../providers/schedule_provider.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLessonPro = ref.watch(isLessonProProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final weekStart = ref.watch(selectedWeekStartProvider);
    final dailyAsync = isLessonPro
        ? ref.watch(dailySchedulesProvider)
        : ref.watch(studentDailySchedulesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isLessonPro ? '스케줄' : '내 레슨',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(selectedDateProvider.notifier).update(DateTime.now());
            },
            icon: Icon(Icons.today, color: Colors.grey[700]),
          ),
        ],
      ),
      floatingActionButton: isLessonPro
          ? FloatingActionButton(
              onPressed: () => _showAddScheduleDialog(context, ref),
              backgroundColor: const Color(0xFF10B981),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          // 주간 달력
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              children: [
                // 월 표시 & 이전/다음 주 버튼
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          ref.read(selectedDateProvider.notifier).update(
                              selectedDate.subtract(const Duration(days: 7)));
                        },
                      ),
                      Text(
                        '${selectedDate.year}년 ${selectedDate.month}월',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          ref.read(selectedDateProvider.notifier).update(
                              selectedDate.add(const Duration(days: 7)));
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                // 요일 헤더
                Row(
                  children: ['월', '화', '수', '목', '금', '토', '일'].map((day) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 8.h),
                // 날짜 선택
                Row(
                  children: List.generate(7, (index) {
                    final date = weekStart.add(Duration(days: index));
                    final isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;
                    final isToday = date.day == DateTime.now().day &&
                        date.month == DateTime.now().month &&
                        date.year == DateTime.now().year;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedDateProvider.notifier).update(date);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : isToday
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: isSelected || isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? const Color(0xFF10B981)
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 선택된 날짜의 스케줄 목록
          Expanded(
            child: dailyAsync.when(
              data: (schedules) {
                if (schedules.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available, size: 48.w, color: Colors.grey[400]),
                        SizedBox(height: 16.h),
                        Text(
                          '이 날짜에 예정된 레슨이 없습니다',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    return _buildScheduleCard(context, ref, schedules[index], isLessonPro: isLessonPro);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, WidgetRef ref, ScheduleEntity schedule, {bool isLessonPro = true}) {
    final statusColor = _getStatusColor(schedule.status);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: isLessonPro ? () => _showScheduleActions(context, ref, schedule) : null,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // 시간 표시
              SizedBox(
                width: 60.w,
                child: Column(
                  children: [
                    Text(
                      schedule.lessonTime,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      '${schedule.durationMinutes}분',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                width: 3.w,
                height: 50.h,
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.studentName ?? '학생',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            schedule.statusLabel,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          schedule.lessonTypeLabel,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    if (schedule.location != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14.w, color: Colors.grey[500]),
                          SizedBox(width: 4.w),
                          Text(
                            schedule.location!,
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled': return Colors.blue;
      case 'completed': return const Color(0xFF10B981);
      case 'cancelled': return Colors.grey;
      case 'no_show': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showScheduleActions(BuildContext context, WidgetRef ref, ScheduleEntity schedule) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${schedule.studentName ?? "학생"} - ${schedule.lessonTime}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                if (schedule.status == 'scheduled') ...[
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                    title: const Text('레슨 완료'),
                    subtitle: const Text('패키지 횟수가 자동으로 차감됩니다'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(scheduleRepositoryProvider)
                          .updateScheduleStatus(schedule.id, 'completed');

                      // 패키지가 연결되어 있으면 횟수 차감
                      if (schedule.packageId != null) {
                        await ref.read(packageRepositoryProvider)
                            .deductLesson(schedule.packageId!);
                        ref.invalidate(packagesProvider);
                      }

                      ref.invalidate(weeklySchedulesProvider);
                      ref.invalidate(todaySchedulesProvider);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.cancel, color: Colors.orange[600]),
                    title: const Text('레슨 취소'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(scheduleRepositoryProvider)
                          .updateScheduleStatus(schedule.id, 'cancelled');
                      ref.invalidate(weeklySchedulesProvider);
                      ref.invalidate(todaySchedulesProvider);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_off, color: Colors.red),
                    title: const Text('노쇼 처리'),
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(scheduleRepositoryProvider)
                          .updateScheduleStatus(schedule.id, 'no_show');
                      ref.invalidate(weeklySchedulesProvider);
                      ref.invalidate(todaySchedulesProvider);
                    },
                  ),
                ],
                // 완료/취소/노쇼 상태에서 "예정으로 복원" 액션
                if (schedule.status != 'scheduled') ...[
                  ListTile(
                    leading: const Icon(Icons.restore, color: Color(0xFF10B981)),
                    title: const Text('예정으로 복원'),
                    subtitle: schedule.status == 'completed' && schedule.packageId != null
                        ? const Text('패키지 횟수가 복원됩니다')
                        : null,
                    onTap: () async {
                      Navigator.pop(context);
                      // 완료 상태였고 패키지가 있으면 횟수 복원
                      if (schedule.status == 'completed' && schedule.packageId != null) {
                        await ref.read(packageRepositoryProvider)
                            .restoreLesson(schedule.packageId!);
                        ref.invalidate(packagesProvider);
                      }
                      await ref.read(scheduleRepositoryProvider)
                          .updateScheduleStatus(schedule.id, 'scheduled');
                      ref.invalidate(weeklySchedulesProvider);
                      ref.invalidate(todaySchedulesProvider);
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('삭제'),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(scheduleRepositoryProvider)
                        .deleteSchedule(schedule.id);
                    ref.invalidate(weeklySchedulesProvider);
                    ref.invalidate(todaySchedulesProvider);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddScheduleDialog(BuildContext context, WidgetRef ref) async {
    try {
      // 학생 목록을 직접 가져옴 (로딩 상태 무시)
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final repo = ref.read(studentRepositoryProvider);
      final students = await repo.getStudents(user.id);

      if (!context.mounted) return;

      if (students.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('먼저 학생을 등록해주세요'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      _showScheduleForm(context, ref, students);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('학생 목록을 불러올 수 없습니다: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showScheduleForm(BuildContext context, WidgetRef ref, List<StudentEntity> students) {
    final sportType = ref.read(currentSportTypeProvider);
    final lessonTypeOptions = SportConstants.lessonTypes(sportType);
    String? selectedStudentId;
    String? selectedPackageId;
    List<PackageEntity> studentPackages = [];
    TimeOfDay selectedTime = TimeOfDay.now();
    int duration = 60;
    String lessonType = lessonTypeOptions.keys.first;
    final locationController = TextEditingController();
    final memoController = TextEditingController();

    // 반복 설정
    bool isRecurring = false;
    String repeatType = 'weekly'; // 'weekly' or 'biweekly'
    DateTime? repeatEndDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16.w, 16.h, 16.w,
                MediaQuery.of(context).viewInsets.bottom + 16.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '레슨 추가',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),

                    // 학생 선택
                    DropdownButtonFormField<String>(
                      value: selectedStudentId,
                      hint: const Text('학생 선택'),
                      items: students.map((s) {
                        return DropdownMenuItem(value: s.id, child: Text(s.studentName));
                      }).toList(),
                      onChanged: (v) async {
                        setState(() {
                          selectedStudentId = v;
                          selectedPackageId = null;
                          studentPackages = [];
                        });
                        if (v != null) {
                          final user = ref.read(currentUserProvider);
                          if (user != null) {
                            final pkgs = await ref.read(packageRepositoryProvider)
                                .getActivePackages(user.id, v);
                            setState(() => studentPackages = pkgs);
                          }
                        }
                      },
                      decoration: InputDecoration(
                        labelText: '학생 *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // 패키지 선택 (학생의 활성 패키지가 있을 때만 표시)
                    if (studentPackages.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: selectedPackageId,
                        hint: const Text('패키지 선택 (선택사항)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('패키지 없이 등록')),
                          ...studentPackages.map((p) {
                            return DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.packageName} (남은 ${p.remainingCount}/${p.totalCount}회)'),
                            );
                          }),
                        ],
                        onChanged: (v) => setState(() => selectedPackageId = v),
                        decoration: InputDecoration(
                          labelText: '레슨 패키지',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // 시간 선택
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) setState(() => selectedTime = time);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '시간 *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          suffixIcon: const Icon(Icons.access_time),
                        ),
                        child: Text(
                          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // 레슨 시간 & 타입
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: duration,
                            items: [30, 45, 60, 90, 120].map((d) {
                              return DropdownMenuItem(value: d, child: Text('${d}분'));
                            }).toList(),
                            onChanged: (v) => setState(() => duration = v!),
                            decoration: InputDecoration(
                              labelText: '레슨 시간',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: lessonType,
                            items: lessonTypeOptions.entries.map((e) {
                              return DropdownMenuItem(value: e.key, child: Text(e.value));
                            }).toList(),
                            onChanged: (v) => setState(() => lessonType = v!),
                            decoration: InputDecoration(
                              labelText: '레슨 타입',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // 장소
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: '장소',
                        hintText: SportConstants.locationHint(sportType),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // 메모
                    TextField(
                      controller: memoController,
                      decoration: InputDecoration(
                        labelText: '메모',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 반복 설정
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '반복 레슨',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Switch(
                                value: isRecurring,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (v) => setState(() {
                                  isRecurring = v;
                                  if (!v) {
                                    repeatEndDate = null;
                                  }
                                }),
                              ),
                            ],
                          ),
                          if (isRecurring) ...[
                            SizedBox(height: 8.h),
                            DropdownButtonFormField<String>(
                              value: repeatType,
                              items: const [
                                DropdownMenuItem(value: 'weekly', child: Text('매주')),
                                DropdownMenuItem(value: 'biweekly', child: Text('격주')),
                              ],
                              onChanged: (v) => setState(() => repeatType = v!),
                              decoration: InputDecoration(
                                labelText: '반복 주기',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            GestureDetector(
                              onTap: () async {
                                final selectedDate = ref.read(selectedDateProvider);
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: repeatEndDate ?? selectedDate.add(const Duration(days: 28)),
                                  firstDate: selectedDate.add(const Duration(days: 1)),
                                  lastDate: selectedDate.add(const Duration(days: 365)),
                                );
                                if (date != null) setState(() => repeatEndDate = date);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: '반복 종료일 *',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  repeatEndDate != null
                                      ? '${repeatEndDate!.year}년 ${repeatEndDate!.month}월 ${repeatEndDate!.day}일'
                                      : '종료일을 선택하세요',
                                  style: TextStyle(
                                    color: repeatEndDate != null ? Colors.black : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: selectedStudentId == null || (isRecurring && repeatEndDate == null)
                            ? null
                            : () async {
                                try {
                                  final user = ref.read(currentUserProvider);
                                  final selectedDate = ref.read(selectedDateProvider);
                                  final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                                  final location = locationController.text.isEmpty
                                      ? null
                                      : locationController.text;
                                  final memo = memoController.text.isEmpty
                                      ? null
                                      : memoController.text;

                                  if (isRecurring && repeatEndDate != null) {
                                    // 반복 레슨 생성
                                    final intervalDays = repeatType == 'weekly' ? 7 : 14;
                                    final List<DateTime> dates = [];
                                    DateTime current = selectedDate;
                                    while (!current.isAfter(repeatEndDate!)) {
                                      dates.add(current);
                                      current = current.add(Duration(days: intervalDays));
                                    }

                                    for (final date in dates) {
                                      await ref.read(scheduleRepositoryProvider).createSchedule(
                                        proId: user!.id,
                                        studentId: selectedStudentId!,
                                        packageId: selectedPackageId,
                                        lessonDate: date,
                                        lessonTime: timeString,
                                        durationMinutes: duration,
                                        lessonType: lessonType,
                                        location: location,
                                        memo: memo,
                                      );
                                    }

                                    ref.invalidate(weeklySchedulesProvider);
                                    ref.invalidate(todaySchedulesProvider);

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('반복 레슨 ${dates.length}개가 추가되었습니다'),
                                          backgroundColor: const Color(0xFF10B981),
                                        ),
                                      );
                                    }
                                  } else {
                                    // 단일 레슨 생성
                                    await ref.read(scheduleRepositoryProvider).createSchedule(
                                      proId: user!.id,
                                      studentId: selectedStudentId!,
                                      packageId: selectedPackageId,
                                      lessonDate: selectedDate,
                                      lessonTime: timeString,
                                      durationMinutes: duration,
                                      lessonType: lessonType,
                                      location: location,
                                      memo: memo,
                                    );

                                    ref.invalidate(weeklySchedulesProvider);
                                    ref.invalidate(todaySchedulesProvider);

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('레슨이 추가되었습니다'),
                                          backgroundColor: Color(0xFF10B981),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('오류: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          isRecurring ? '반복 레슨 추가' : '레슨 추가',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
