import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
              '안녕하세요! 👋',
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
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 알림 페이지
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: Colors.grey[700],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: 설정 페이지
            },
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 오늘 일정 요약
            _buildTodaySchedule(),
            SizedBox(height: 24.h),
            
            // 주요 통계
            _buildStatsGrid(),
            SizedBox(height: 24.h),
            
            // 빠른 액션
            _buildQuickActions(context),
            SizedBox(height: 24.h),
            
            // 최근 활동
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
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
              Icon(
                Icons.today,
                color: Colors.white,
                size: 24.w,
              ),
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
          Row(
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
                      '3건', // TODO: 실제 데이터
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
                      '예상 수입',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '₩180,000', // TODO: 실제 데이터
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
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
          value: '24명', // TODO: 실제 데이터
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: '이번 달 수입',
          value: '₩2,400,000', // TODO: 실제 데이터
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _buildStatCard(
          title: '이번 주 레슨',
          value: '18회', // TODO: 실제 데이터
          icon: Icons.sports_golf,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: '완료율',
          value: '95%', // TODO: 실제 데이터
          icon: Icons.trending_up,
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
          Icon(
            icon,
            size: 32.w,
            color: color,
          ),
          Spacer(),
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
                onTap: () => context.push('/schedule'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.note_add,
                label: '노트 작성',
                onTap: () => context.push('/lessons'),
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
            Icon(
              icon,
              size: 28.w,
              color: const Color(0xFF10B981),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 활동',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 전체 활동 보기
              },
              child: Text(
                '전체 보기',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // TODO: 실제 데이터
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              // TODO: 실제 데이터 바인딩
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                  child: Icon(
                    Icons.sports_golf,
                    color: const Color(0xFF10B981),
                    size: 20.w,
                  ),
                ),
                title: Text(
                  '김철수 학생과 레슨 완료',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  '2시간 전',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}