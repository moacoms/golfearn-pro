import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../packages/data/models/package_model.dart';
import '../../../packages/domain/entities/package_entity.dart';
import '../../../../core/theme/app_theme.dart';

// ──────────────────────────────────────────────
// Student-side providers (no code generation needed)
// ──────────────────────────────────────────────

/// 현재 사용자의 lesson_students 레코드 ID 목록 조회
final _myStudentRecordIdsProvider = FutureProvider<List<String>>((ref) async {
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

/// 학생의 총 레슨 횟수 (완료된 스케줄 수)
final _myTotalLessonCountProvider = FutureProvider<int>((ref) async {
  final studentIds = await ref.watch(_myStudentRecordIdsProvider.future);
  if (studentIds.isEmpty) return 0;

  final response = await Supabase.instance.client
      .from('lesson_schedules')
      .select('id')
      .inFilter('student_id', studentIds)
      .eq('status', 'completed');

  return List.from(response).length;
});

/// 학생의 활성 패키지 목록
final _myActivePackagesProvider =
    FutureProvider<List<PackageEntity>>((ref) async {
  final studentIds = await ref.watch(_myStudentRecordIdsProvider.future);
  if (studentIds.isEmpty) return [];

  final response = await Supabase.instance.client
      .from('lesson_packages')
      .select('*')
      .inFilter('student_id', studentIds)
      .eq('status', 'active')
      .order('created_at', ascending: false);

  final list = List<Map<String, dynamic>>.from(response);
  return list.map((json) => PackageModel.fromJson(json).toEntity()).toList();
});

/// 학생의 다가오는 레슨 (미래 예정된 스케줄, 프로 이름 포함)
final _myUpcomingLessonsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final studentIds = await ref.watch(_myStudentRecordIdsProvider.future);
  if (studentIds.isEmpty) return [];

  final today = DateTime.now().toIso8601String().split('T').first;

  final response = await Supabase.instance.client
      .from('lesson_schedules')
      .select('*, profiles!lesson_schedules_pro_id_fkey(full_name)')
      .inFilter('student_id', studentIds)
      .eq('status', 'scheduled')
      .gte('lesson_date', today)
      .order('lesson_date')
      .order('lesson_time')
      .limit(5);

  return List<Map<String, dynamic>>.from(response);
});

// ──────────────────────────────────────────────
// StudentDashboardPage
// ──────────────────────────────────────────────

class StudentDashboardPage extends ConsumerWidget {
  const StudentDashboardPage({super.key});

  static const _primary = AppTheme.primaryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.fullName ?? '학생';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: () async {
            ref.invalidate(_myStudentRecordIdsProvider);
            ref.invalidate(_myTotalLessonCountProvider);
            ref.invalidate(_myActivePackagesProvider);
            ref.invalidate(_myUpcomingLessonsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(userName),
                SizedBox(height: 24.h),
                _buildQuickInfoCards(ref),
                SizedBox(height: 24.h),
                _buildUpcomingLessonsSection(ref),
                SizedBox(height: 24.h),
                _buildMyPackagesSection(ref),
                SizedBox(height: 24.h),
                _buildFindProSection(context),
                SizedBox(height: 24.h),
                _buildContactProSection(),
                SizedBox(height: 24.h),
                _buildSwitchToProSection(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 1. Welcome header
  // ──────────────────────────────────────────────

  Widget _buildWelcomeHeader(String userName) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요, ${userName}님',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '골프 레슨 학생',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 2. Quick info cards
  // ──────────────────────────────────────────────

  Widget _buildQuickInfoCards(WidgetRef ref) {
    final lessonCountAsync = ref.watch(_myTotalLessonCountProvider);
    final packagesAsync = ref.watch(_myActivePackagesProvider);

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.sports_golf,
            title: '총 레슨 횟수',
            value: lessonCountAsync.when(
              data: (count) => '${count}회',
              loading: () => '...',
              error: (_, __) => '0회',
            ),
            color: Colors.blue,
            isLoading: lessonCountAsync.isLoading,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.card_giftcard,
            title: '활성 패키지',
            value: packagesAsync.when(
              data: (packages) => '${packages.length}개',
              loading: () => '...',
              error: (_, __) => '0개',
            ),
            color: Colors.orange,
            isLoading: packagesAsync.isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isLoading = false,
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
          Icon(icon, size: 28.w, color: color),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 3. Upcoming lessons section
  // ──────────────────────────────────────────────

  Widget _buildUpcomingLessonsSection(WidgetRef ref) {
    final upcomingAsync = ref.watch(_myUpcomingLessonsProvider);

    return Container(
      width: double.infinity,
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
              Icon(Icons.schedule, size: 20.w, color: _primary),
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
          SizedBox(height: 20.h),
          upcomingAsync.when(
            data: (lessons) {
              if (lessons.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.event_available,
                  message: '예정된 레슨이 없습니다',
                  subMessage: '레슨프로가 일정을 등록하면 여기에 표시됩니다',
                );
              }
              return Column(
                children: lessons
                    .map((lesson) => _buildUpcomingLessonItem(lesson))
                    .toList(),
              );
            },
            loading: () => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primary,
                  ),
                ),
              ),
            ),
            error: (_, __) => _buildEmptyState(
              icon: Icons.event_available,
              message: '예정된 레슨이 없습니다',
              subMessage: '레슨프로가 일정을 등록하면 여기에 표시됩니다',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingLessonItem(Map<String, dynamic> lessonData) {
    final lessonDate = DateTime.parse(lessonData['lesson_date'] as String);
    final lessonTime = lessonData['lesson_time'] as String? ?? '';
    final duration = lessonData['duration_minutes'] as int? ?? 60;
    final lessonType = lessonData['lesson_type'] as String?;
    final location = lessonData['location'] as String?;

    // Pro name from joined profiles
    String proName = '레슨프로';
    final profiles = lessonData['profiles'];
    if (profiles != null && profiles is Map) {
      proName = (profiles['full_name'] as String?) ?? '레슨프로';
    }

    final timeStr = lessonTime.length >= 5 ? lessonTime.substring(0, 5) : lessonTime;
    const weekdayKo = ['', '월', '화', '수', '목', '금', '토', '일'];
    final dayLabel = weekdayKo[lessonDate.weekday];

    // Lesson type label
    String typeLabel;
    switch (lessonType) {
      case 'regular':
        typeLabel = '일반 레슨';
        break;
      case 'playing':
        typeLabel = '필드 레슨';
        break;
      case 'short_game':
        typeLabel = '숏게임';
        break;
      case 'putting':
        typeLabel = '퍼팅';
        break;
      default:
        typeLabel = lessonType ?? '일반 레슨';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: _primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 52.w,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('M/d').format(lessonDate),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: _primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$timeStr  |  ${duration}분',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$proName  ·  $typeLabel',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (location != null && location.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    location,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '예정',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 4. My packages section
  // ──────────────────────────────────────────────

  Widget _buildMyPackagesSection(WidgetRef ref) {
    final packagesAsync = ref.watch(_myActivePackagesProvider);

    return Container(
      width: double.infinity,
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
              Icon(Icons.card_giftcard, size: 20.w, color: _primary),
              SizedBox(width: 8.w),
              Text(
                '내 레슨 패키지',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          packagesAsync.when(
            data: (packages) {
              if (packages.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.inventory_2_outlined,
                  message: '활성 패키지가 없습니다',
                  subMessage: '레슨프로에게 패키지를 문의해 보세요',
                );
              }
              return Column(
                children: packages
                    .map((pkg) => _buildPackageItem(pkg))
                    .toList(),
              );
            },
            loading: () => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primary,
                  ),
                ),
              ),
            ),
            error: (_, __) => _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              message: '활성 패키지가 없습니다',
              subMessage: '레슨프로에게 패키지를 문의해 보세요',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageItem(PackageEntity pkg) {
    final progress = pkg.totalCount > 0
        ? pkg.usedCount / pkg.totalCount
        : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.orange.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pkg.packageName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  pkg.statusLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8.h,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 0.8 ? Colors.red : _primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${pkg.usedCount}/${pkg.totalCount}회 사용  |  잔여 ${pkg.remainingCount}회',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pkg.endDate != null) ...[
            SizedBox(height: 4.h),
            Text(
              '만료일: ${DateFormat('yyyy.MM.dd').format(pkg.endDate!)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 5. Contact my pro section
  // ──────────────────────────────────────────────

  Widget _buildContactProSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.support_agent,
              size: 28.w,
              color: _primary,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '레슨프로에게 문의하세요',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '레슨 일정, 패키지 등 궁금한 점이 있으면 담당 프로에게 연락하세요.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 6. Find Pro section
  // ──────────────────────────────────────────────

  Widget _buildFindProSection(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/find-pro'),
      child: Container(
        width: double.infinity,
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.search,
                size: 28.w,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '레슨프로 찾기',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '등록된 골프 레슨프로를 검색하고 연락할 수 있습니다',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.w),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 7. Switch to Pro section
  // ──────────────────────────────────────────────

  Widget _buildSwitchToProSection(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.sports_golf,
            size: 40.w,
            color: _primary,
          ),
          SizedBox(height: 12.h),
          Text(
            '레슨프로이신가요?',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '레슨프로로 전환하면 학생 관리, 스케줄, 패키지, 수입 관리 등\n프로 전용 기능을 사용할 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showSwitchToProDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '레슨프로로 전환하기',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSwitchToProDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '레슨프로로 전환',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '레슨프로로 전환하시겠습니까?\n\n전환 후 학생 관리, 스케줄 관리 등 프로 전용 기능을 사용할 수 있습니다.',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) return;

                await Supabase.instance.client
                    .from('profiles')
                    .update({
                      'is_lesson_pro': true,
                      'is_student': false,
                      'updated_at': DateTime.now().toIso8601String(),
                    })
                    .eq('id', userId);

                final currentUser = ref.read(currentUserProvider);
                if (currentUser != null) {
                  ref.read(authControllerProvider.notifier).state = AuthState(
                    user: currentUser.copyWith(isLessonPro: true, isStudent: false),
                  );
                }

                ref.invalidate(authControllerProvider);
                ref.invalidate(currentUserProvider);
                ref.invalidate(isLessonProProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('레슨프로로 전환되었습니다!'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                  context.go('/home');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('전환 실패: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              '전환하기',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Shared empty state widget
  // ──────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subMessage,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Icon(icon, size: 40.w, color: Colors.grey[300]),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subMessage,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
