import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/income_entity.dart';
import '../providers/income_provider.dart';

class IncomePage extends ConsumerWidget {
  const IncomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final recordsAsync = ref.watch(monthlyIncomeRecordsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '수입 관리',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(context, ref),
        backgroundColor: const Color(0xFF10B981),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // 월 선택 & 총 수입
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // 월 선택
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        ref.read(selectedMonthProvider.notifier).update(
                            DateTime(selectedMonth.year, selectedMonth.month - 1));
                      },
                    ),
                    Text(
                      '${selectedMonth.year}년 ${selectedMonth.month}월',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        ref.read(selectedMonthProvider.notifier).update(
                            DateTime(selectedMonth.year, selectedMonth.month + 1));
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // 월간 총 수입
                recordsAsync.when(
                  data: (records) {
                    final total = records.fold<int>(0, (sum, r) => sum + r.amount);
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '이번 달 총 수입',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _formatCurrency(total),
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${records.length}건',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // 카테고리별 & 결제수단별 통계
          recordsAsync.when(
            data: (records) {
              if (records.isEmpty) return const SizedBox.shrink();
              return _buildStatisticsSection(records);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // 수입 기록 리스트
          Expanded(
            child: recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48.w, color: Colors.grey[400]),
                        SizedBox(height: 16.h),
                        Text(
                          '이번 달 수입 기록이 없습니다',
                          style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                // 일자별 그룹핑
                final grouped = <String, List<IncomeEntity>>{};
                for (final r in records) {
                  final key = '${r.incomeDate.year}.${r.incomeDate.month.toString().padLeft(2, '0')}.${r.incomeDate.day.toString().padLeft(2, '0')}';
                  grouped.putIfAbsent(key, () => []).add(r);
                }
                final dateKeys = grouped.keys.toList();

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(monthlyIncomeRecordsProvider),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: dateKeys.length,
                    itemBuilder: (context, index) {
                      final dateKey = dateKeys[index];
                      final dayRecords = grouped[dateKey]!;
                      final dayTotal = dayRecords.fold<int>(0, (sum, r) => sum + r.amount);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 일자 헤더 + 소계
                          Padding(
                            padding: EdgeInsets.only(top: index > 0 ? 12.h : 0, bottom: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateKey,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  _formatCurrency(dayTotal),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...dayRecords.map((r) => _buildIncomeCard(context, ref, r)),
                        ],
                      );
                    },
                  ),
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

  Widget _buildStatisticsSection(List<IncomeEntity> records) {
    // 카테고리별 합계
    final lessonTotal = records
        .where((r) => r.category == 'lesson')
        .fold<int>(0, (sum, r) => sum + r.amount);
    final packageTotal = records
        .where((r) => r.category == 'package')
        .fold<int>(0, (sum, r) => sum + r.amount);
    final otherCategoryTotal = records
        .where((r) => r.category == 'other')
        .fold<int>(0, (sum, r) => sum + r.amount);

    // 결제수단별 합계
    final cashTotal = records
        .where((r) => r.paymentMethod == 'cash')
        .fold<int>(0, (sum, r) => sum + r.amount);
    final cardTotal = records
        .where((r) => r.paymentMethod == 'card')
        .fold<int>(0, (sum, r) => sum + r.amount);
    final transferTotal = records
        .where((r) => r.paymentMethod == 'transfer')
        .fold<int>(0, (sum, r) => sum + r.amount);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          // 카테고리별 수입
          Text(
            '카테고리별',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sports_golf,
                  label: '레슨비',
                  amount: lessonTotal,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory,
                  label: '패키지',
                  amount: packageTotal,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt,
                  label: '기타',
                  amount: otherCategoryTotal,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 결제수단별 수입
          Text(
            '결제수단별',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.money,
                  label: '현금',
                  amount: cashTotal,
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.credit_card,
                  label: '카드',
                  amount: cardTotal,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.account_balance,
                  label: '이체',
                  amount: transferTotal,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int amount,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18.w, color: color),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context, WidgetRef ref, IncomeEntity record) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(record.category).withOpacity(0.1),
          child: Icon(
            _getCategoryIcon(record.category),
            color: _getCategoryColor(record.category),
            size: 20.w,
          ),
        ),
        title: Text(
          record.description ?? record.categoryLabel,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${record.studentName ?? ""} ${record.paymentMethodLabel} | ${_formatShortDate(record.incomeDate)}',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        trailing: Text(
          _formatCurrency(record.amount),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF10B981),
          ),
        ),
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('수입 기록 삭제'),
              content: const Text('이 수입 기록을 삭제하시겠습니까?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref.read(incomeRepositoryProvider).deleteIncomeRecord(record.id);
                    ref.invalidate(monthlyIncomeRecordsProvider);
                    ref.invalidate(monthlyTotalIncomeProvider);
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('삭제'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'lesson': return Colors.blue;
      case 'package': return Colors.purple;
      case 'other': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'lesson': return Icons.sports_golf;
      case 'package': return Icons.inventory;
      case 'other': return Icons.receipt;
      default: return Icons.attach_money;
    }
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '₩$buffer';
  }

  String _formatShortDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  Future<void> _showAddIncomeDialog(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final repo = ref.read(studentRepositoryProvider);
      final students = await repo.getStudents(user.id);
      if (!context.mounted) return;
      _showIncomeForm(context, ref, students);
    } catch (_) {
      if (context.mounted) _showIncomeForm(context, ref, []);
    }
  }

  void _showIncomeForm(BuildContext context, WidgetRef ref, List<StudentEntity> students) {
    String? selectedStudentId;
    String category = 'lesson';
    String paymentMethod = 'cash';
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime incomeDate = DateTime.now();

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
                    Text('수입 기록 추가', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.h),

                    // 금액
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '금액 (원) *',
                        hintText: '예: 60000',
                        prefixText: '₩ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // 카테고리 & 결제 방법
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: category,
                            items: const [
                              DropdownMenuItem(value: 'lesson', child: Text('레슨비')),
                              DropdownMenuItem(value: 'package', child: Text('패키지')),
                              DropdownMenuItem(value: 'other', child: Text('기타')),
                            ],
                            onChanged: (v) => setState(() => category = v!),
                            decoration: InputDecoration(
                              labelText: '카테고리',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: paymentMethod,
                            items: const [
                              DropdownMenuItem(value: 'cash', child: Text('현금')),
                              DropdownMenuItem(value: 'card', child: Text('카드')),
                              DropdownMenuItem(value: 'transfer', child: Text('이체')),
                              DropdownMenuItem(value: 'other', child: Text('기타')),
                            ],
                            onChanged: (v) => setState(() => paymentMethod = v!),
                            decoration: InputDecoration(
                              labelText: '결제 방법',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // 학생 선택 (선택사항)
                    if (students.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedStudentId,
                        hint: const Text('학생 선택 (선택사항)'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('선택 안함')),
                          ...students.map((s) {
                            return DropdownMenuItem(value: s.id, child: Text(s.studentName));
                          }),
                        ],
                        onChanged: (v) => setState(() => selectedStudentId = v),
                        decoration: InputDecoration(
                          labelText: '학생',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                      ),
                    SizedBox(height: 12.h),

                    // 설명
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: '설명',
                        hintText: '예: 3월 둘째주 레슨비',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          final amount = int.tryParse(amountController.text);
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('올바른 금액을 입력해주세요'), backgroundColor: Colors.orange),
                            );
                            return;
                          }

                          try {
                            final user = ref.read(currentUserProvider);
                            await ref.read(incomeRepositoryProvider).createIncomeRecord(
                              proId: user!.id,
                              studentId: selectedStudentId,
                              category: category,
                              amount: amount,
                              incomeDate: incomeDate,
                              description: descriptionController.text.isEmpty
                                  ? null
                                  : descriptionController.text,
                              paymentMethod: paymentMethod,
                            );

                            ref.invalidate(monthlyIncomeRecordsProvider);
                            ref.invalidate(monthlyTotalIncomeProvider);

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('수입이 기록되었습니다'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('수입 기록', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
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
