import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../../../income/presentation/providers/income_provider.dart';
import '../../../packages/presentation/providers/package_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요!',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${currentUser?.fullName ?? '레슨프로'}님',
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todaySchedulesProvider);
          ref.invalidate(studentCountProvider);
          ref.invalidate(monthlyTotalIncomeProvider);
          ref.invalidate(weeklyLessonCountProvider);
          ref.invalidate(packagesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodaySchedule(ref),
              SizedBox(height: 16.h),
              _buildUpcomingLessons(ref),
              SizedBox(height: 24.h),
              _buildStatsGrid(ref),
              SizedBox(height: 24.h),
              _buildWeeklyLessonChart(ref),
              SizedBox(height: 24.h),
              _buildPackageAlerts(ref),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 1. Today's schedule card (existing)
  // ──────────────────────────────────────────────

  Widget _buildTodaySchedule(WidgetRef ref) {
    final todayAsync = ref.watch(todaySchedulesProvider);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: Colors.white, size: 24.w),
              SizedBox(width: 8.w),
              Text(
                '오늘의 일정',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          todayAsync.when(
            data: (schedules) {
              final scheduledCount =
                  schedules.where((s) => s.status == 'scheduled').length;
              final completedCount =
                  schedules.where((s) => s.status == 'completed').length;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '예정된 레슨',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${scheduledCount}건',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '완료된 레슨',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${completedCount}건',
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, __) => Text(
              '데이터를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 2. Upcoming lessons list (new)
  // ──────────────────────────────────────────────

  Widget _buildUpcomingLessons(WidgetRef ref) {
    final todayAsync = ref.watch(todaySchedulesProvider);

    return todayAsync.when(
      data: (schedules) {
        final upcoming = schedules
            .where((s) => s.status == 'scheduled')
            .toList()
          ..sort((a, b) => a.lessonTime.compareTo(b.lessonTime));

        if (upcoming.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 20.w, color: const Color(0xFF10B981)),
                  SizedBox(width: 8.w),
                  Text(
                    '다가오는 레슨',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ...upcoming.map((schedule) => _buildUpcomingLessonItem(schedule)),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildUpcomingLessonItem(dynamic schedule) {
    Color statusColor;
    switch (schedule.status) {
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'no_show':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            schedule.lessonTime,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.studentName ?? '학생',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${schedule.durationMinutes}분',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
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
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 3. Stats grid (improved)
  // ──────────────────────────────────────────────

  Widget _buildStatsGrid(WidgetRef ref) {
    final studentCountAsync = ref.watch(studentCountProvider);
    final monthlyIncomeAsync = ref.watch(monthlyTotalIncomeProvider);
    final weeklyLessonAsync = ref.watch(weeklyLessonCountProvider);
    final packagesAsync = ref.watch(packagesProvider);

    final expiringCount = packagesAsync.when(
      data: (packages) {
        final now = DateTime.now();
        return packages.where((p) {
          if (p.status != 'active') return false;
          final lowCount = p.remainingCount <= 2;
          final expiringSoon = p.endDate != null &&
              p.endDate!.difference(now).inDays <= 7 &&
              p.endDate!.isAfter(now);
          return lowCount || expiringSoon;
        }).length;
      },
      loading: () => 0,
      error: (_, __) => 0,
    );

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: '총 학생',
          value: studentCountAsync.when(
            data: (count) => '${count}명',
            loading: () => '...',
            error: (_, __) => '-',
          ),
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: '이번 달 수입',
          value: monthlyIncomeAsync.when(
            data: (amount) => _formatCurrency(amount),
            loading: () => '...',
            error: (_, __) => '-',
          ),
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _buildStatCard(
          title: '이번 주 레슨',
          value: weeklyLessonAsync.when(
            data: (count) => '${count}회',
            loading: () => '...',
            error: (_, __) => '-',
          ),
          icon: Icons.sports_golf,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: '만료 임박 패키지',
          value: '$expiringCount건',
          icon: Icons.warning_amber_rounded,
          color: expiringCount > 0 ? Colors.red : Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32.w, color: color),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 4. Weekly lesson chart (new)
  // ──────────────────────────────────────────────

  Widget _buildWeeklyLessonChart(WidgetRef ref) {
    final todayAsync = ref.watch(weeklySchedulesProvider);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, size: 20.w, color: const Color(0xFF10B981)),
              SizedBox(width: 8.w),
              Text(
                '이번 주 레슨 현황',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 160.h,
            child: todayAsync.when(
              data: (schedules) {
                // Count lessons per weekday (Mon=1 .. Sun=7)
                final dayCounts = List.filled(7, 0);
                for (final s in schedules) {
                  final wd = s.lessonDate.weekday; // 1=Mon, 7=Sun
                  if (wd >= 1 && wd <= 7) {
                    dayCounts[wd - 1]++;
                  }
                }

                final maxCount = dayCounts.reduce((a, b) => a > b ? a : b);
                final maxY = maxCount > 0 ? (maxCount + 1).toDouble() : 5.0;

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final count = rod.toY.toInt();
                          return BarTooltipItem(
                            '${count}건',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['월', '화', '수', '목', '금', '토', '일'];
                            final idx = value.toInt();
                            if (idx < 0 || idx >= days.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                days[idx],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                          reservedSize: 24.h,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (i) {
                      final isToday = DateTime.now().weekday == (i + 1);
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: dayCounts[i].toDouble(),
                            color: isToday
                                ? const Color(0xFF10B981)
                                : const Color(0xFF10B981).withOpacity(0.4),
                            width: 20.w,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4.r),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
              loading: () => Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    color: Color(0xFF10B981),
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (_, __) => Center(
                child: Text(
                  '차트를 불러올 수 없습니다',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 5. Package alerts (new)
  // ──────────────────────────────────────────────

  Widget _buildPackageAlerts(WidgetRef ref) {
    final packagesAsync = ref.watch(packagesProvider);

    return packagesAsync.when(
      data: (packages) {
        final now = DateTime.now();
        final alertPackages = packages.where((p) {
          if (p.status != 'active') return false;
          final lowCount = p.remainingCount <= 2;
          final expiringSoon = p.endDate != null &&
              p.endDate!.difference(now).inDays <= 7 &&
              p.endDate!.isAfter(now);
          return lowCount || expiringSoon;
        }).toList();

        if (alertPackages.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notification_important,
                    size: 20.w, color: Colors.red),
                SizedBox(width: 8.w),
                Text(
                  '패키지 만료 알림',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...alertPackages.map((pkg) => _buildPackageAlertItem(pkg)),
            SizedBox(height: 24.h),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPackageAlertItem(dynamic pkg) {
    final now = DateTime.now();
    final isLowCount = pkg.remainingCount <= 2;
    final isExpiringSoon = pkg.endDate != null &&
        pkg.endDate!.difference(now).inDays <= 7 &&
        pkg.endDate!.isAfter(now);

    String alertText;
    Color alertColor;
    IconData alertIcon;

    if (isLowCount && isExpiringSoon) {
      alertText = '잔여 ${pkg.remainingCount}회 / 만료 임박';
      alertColor = Colors.red;
      alertIcon = Icons.error;
    } else if (isLowCount) {
      alertText = '잔여 ${pkg.remainingCount}회';
      alertColor = Colors.orange;
      alertIcon = Icons.warning;
    } else {
      final daysLeft = pkg.endDate!.difference(now).inDays;
      alertText = '${daysLeft}일 후 만료';
      alertColor = Colors.orange;
      alertIcon = Icons.timer;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: alertColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(alertIcon, size: 20.w, color: alertColor),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.studentName ?? '학생',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  pkg.packageName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: alertColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              alertText,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: alertColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 6. Quick actions (improved with income button)
  // ──────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.person_add,
                label: '학생 추가',
                onTap: () => context.push('/students/new'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle,
                label: '레슨 추가',
                onTap: () => context.go('/schedule'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.note_add,
                label: '노트 작성',
                onTap: () => context.go('/lessons'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.account_balance_wallet,
                label: '수입 관리',
                onTap: () => context.go('/income'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28.w, color: const Color(0xFF10B981)),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount == 0) return '₩0';
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '₩$buffer';
  }
}
