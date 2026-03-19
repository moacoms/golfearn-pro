import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../../schedule/presentation/providers/schedule_provider.dart';
import '../../../income/presentation/providers/income_provider.dart';

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
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodaySchedule(ref),
              SizedBox(height: 24.h),
              _buildStatsGrid(ref),
              SizedBox(height: 24.h),
              _buildQuickActions(context),
            ],
          ),
        ),
      ),
    );
  }

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
              final scheduledCount = schedules.where((s) => s.status == 'scheduled').length;
              final completedCount = schedules.where((s) => s.status == 'completed').length;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '예정된 레슨',
                          style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.8)),
                        ),
                        Text(
                          '${scheduledCount}건',
                          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
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
                          style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.8)),
                        ),
                        Text(
                          '${completedCount}건',
                          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: SizedBox(
                width: 24.w, height: 24.w,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
            error: (_, __) => Text(
              '데이터를 불러올 수 없습니다',
              style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(WidgetRef ref) {
    final studentCountAsync = ref.watch(studentCountProvider);
    final monthlyIncomeAsync = ref.watch(monthlyTotalIncomeProvider);
    final weeklyLessonAsync = ref.watch(weeklyLessonCountProvider);

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
          title: '오늘 날짜',
          value: '${DateTime.now().month}/${DateTime.now().day}',
          icon: Icons.calendar_today,
          color: Colors.purple,
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
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
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
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey[700]),
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
