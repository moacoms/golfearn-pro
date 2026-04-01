import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../income/domain/entities/income_entity.dart';
import '../../../income/presentation/providers/income_provider.dart';
import '../../domain/entities/student_entity.dart';
import '../providers/student_provider.dart';
import 'student_form_page.dart';
import '../../../../core/theme/app_theme.dart';

class StudentDetailPage extends ConsumerWidget {
  final String studentId;

  const StudentDetailPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));

    return studentAsync.when(
      data: (student) => _buildContent(context, ref, student),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('학생 상세')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('학생 상세')),
        body: Center(child: Text('오류: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, StudentEntity student) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          student.studentName,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StudentFormPage(student: student),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
          ),
          IconButton(
            onPressed: () => _showDeleteDialog(context, ref, student),
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // 프로필 헤더
            _buildProfileHeader(student),
            SizedBox(height: 16.h),

            // 골프 정보
            _buildInfoSection('골프 정보', [
              _buildInfoRow('레벨', student.currentLevel ?? '-'),
              _buildInfoRow('목표', student.goal ?? '-'),
              _buildInfoRow('평균 스코어', student.averageScore != null ? '${student.averageScore}타' : '-'),
              _buildInfoRow('골프 시작일', _formatDate(student.startedGolfAt)),
              _buildInfoRow('총 레슨 횟수', '${student.totalLessonCount}회'),
              _buildInfoRow('마지막 레슨', _formatDate(student.lastLessonAt)),
            ]),
            SizedBox(height: 16.h),

            // 개인 정보
            _buildInfoSection('개인 정보', [
              _buildInfoRow('전화번호', student.studentPhone ?? '-'),
              _buildInfoRow('이메일', student.studentEmail ?? '-'),
              _buildInfoRow('성별', student.gender ?? '-'),
              _buildInfoRow('생년월일', _formatDate(student.birthDate)),
            ]),

            if (student.studentMemo != null && student.studentMemo!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _buildInfoSection('메모', [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    student.studentMemo!,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700], height: 1.5),
                  ),
                ),
              ]),
            ],

            // 그룹 & 가족 정보
            if (student.groupName != null || student.familyGroupId != null) ...[
              SizedBox(height: 16.h),
              _buildInfoSection('그룹/가족 정보', [
                if (student.groupName != null)
                  _buildInfoRow('그룹', student.groupName!),
                if (student.familyGroupId != null)
                  _buildFamilySection(context, ref, student),
              ]),
            ],

            // 결제 내역
            SizedBox(height: 16.h),
            _buildPaymentHistory(ref, student.id),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(StudentEntity student) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              student.studentName.isNotEmpty ? student.studentName[0] : '?',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            student.studentName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (student.currentLevel != null) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                student.currentLevel!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilySection(BuildContext context, WidgetRef ref, StudentEntity student) {
    final familyAsync = ref.watch(familyMembersProvider(student.familyGroupId!));
    return familyAsync.when(
      data: (members) {
        final others = members.where((m) => m.id != student.id).toList();
        if (others.isEmpty) return const SizedBox.shrink();
        return Column(
          children: others.map((m) => InkWell(
            onTap: () => context.push('/students/${m.id}'),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                children: [
                  Icon(Icons.family_restroom, size: 18.w, color: Colors.orange),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      m.studentName,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18.w, color: Colors.grey[400]),
                ],
              ),
            ),
          )).toList(),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.all(16.w),
        child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPaymentHistory(WidgetRef ref, String studentId) {
    final incomeAsync = ref.watch(studentIncomeRecordsProvider(studentId));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: Text(
              '결제 내역',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          incomeAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    '결제 내역이 없습니다',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
                );
              }
              final total = records.fold<int>(0, (sum, r) => sum + r.amount);
              return Column(
                children: [
                  // 총 결제 금액
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('총 결제 금액', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        Text(
                          _formatCurrency(total),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // 개별 내역
                  ...records.map((r) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.description ?? r.categoryLabel,
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${r.incomeDate.year}.${r.incomeDate.month.toString().padLeft(2, '0')}.${r.incomeDate.day.toString().padLeft(2, '0')} | ${r.paymentMethodLabel}',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatCurrency(r.amount),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )),
                  SizedBox(height: 12.h),
                ],
              );
            },
            loading: () => Padding(
              padding: EdgeInsets.all(16.w),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Padding(
              padding: EdgeInsets.all(16.w),
              child: Text('결제 내역을 불러올 수 없습니다', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '${buffer}원';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, StudentEntity student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학생 삭제'),
        content: Text('${student.studentName} 학생을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(studentRepositoryProvider).deleteStudent(student.id);
                ref.invalidate(studentsProvider);
                ref.invalidate(studentCountProvider);
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('학생이 삭제되었습니다'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
