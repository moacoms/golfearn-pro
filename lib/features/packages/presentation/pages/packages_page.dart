import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../domain/entities/package_entity.dart';
import '../providers/package_provider.dart';
import '../../../../core/theme/app_theme.dart';

class PackagesPage extends ConsumerWidget {
  const PackagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(packagesProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '레슨 패키지',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPackageDialog(context, ref),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: packagesAsync.when(
        data: (packages) {
          if (packages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64.w, color: Colors.grey[400]),
                  SizedBox(height: 16.h),
                  Text(
                    '등록된 패키지가 없습니다',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '학생별 레슨 횟수권을 등록해보세요',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(packagesProvider),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: packages.length,
              itemBuilder: (context, index) => _buildPackageCard(context, ref, packages[index]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('데이터를 불러올 수 없습니다')),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, WidgetRef ref, PackageEntity pkg) {
    final isActive = pkg.status == 'active';
    final progressColor = isActive ? AppTheme.primaryColor : Colors.grey;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => _showPackageActions(context, ref, pkg),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 학생명 + 상태
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: progressColor.withOpacity(0.1),
                  child: Icon(Icons.inventory, size: 20.w, color: progressColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg.packageName,
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        pkg.studentName ?? '학생',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // 상태 배지
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(pkg.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    pkg.statusLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(pkg.status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 진행률 바
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '사용 ${pkg.usedCount}회 / 총 ${pkg.totalCount}회',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '남은 횟수: ${pkg.remainingCount}회',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: pkg.remainingCount > 0 ? AppTheme.primaryColor : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: pkg.totalCount > 0 ? pkg.usedCount / pkg.totalCount : 0,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(progressColor),
                          minHeight: 8.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 하단: 금액 + 결제상태
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatCurrency(pkg.price),
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _getPaymentColor(pkg.paymentStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        pkg.paymentStatusLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: _getPaymentColor(pkg.paymentStatus),
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      SizedBox(width: 8.w),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'cancel') {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('패키지 취소'),
                                content: const Text('이 패키지를 취소하시겠습니까?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('아니오')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('취소하기'),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await ref.read(packageRepositoryProvider).cancelPackage(pkg.id);
                              ref.invalidate(packagesProvider);
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'cancel', child: Text('패키지 취소', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showPackageActions(BuildContext context, WidgetRef ref, PackageEntity pkg) {
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
                  '${pkg.packageName} — ${pkg.studentName ?? "학생"}',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),

                // 결제 상태 변경
                Text('결제 상태 변경', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildStatusButton(context, ref, pkg, 'pending', '미결제', Colors.red),
                    SizedBox(width: 8.w),
                    _buildStatusButton(context, ref, pkg, 'partial', '부분결제', Colors.orange),
                    SizedBox(width: 8.w),
                    _buildStatusButton(context, ref, pkg, 'paid', '결제완료', AppTheme.primaryColor),
                  ],
                ),
                SizedBox(height: 20.h),

                // 패키지 상태 변경
                Text('패키지 상태 변경', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildPackageStatusButton(context, ref, pkg, 'active', '사용중', AppTheme.primaryColor),
                    SizedBox(width: 8.w),
                    _buildPackageStatusButton(context, ref, pkg, 'expired', '만료', Colors.orange),
                    SizedBox(width: 8.w),
                    _buildPackageStatusButton(context, ref, pkg, 'cancelled', '취소', Colors.grey),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(BuildContext context, WidgetRef ref, PackageEntity pkg, String status, String label, Color color) {
    final isSelected = pkg.paymentStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: isSelected ? null : () async {
          Navigator.pop(context);
          try {
            await ref.read(packageRepositoryProvider).updatePackageField(pkg.id, {'payment_status': status});
            ref.invalidate(packagesProvider);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('변경에 실패했습니다. 다시 시도해주세요.'), backgroundColor: AppTheme.errorColor),
              );
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageStatusButton(BuildContext context, WidgetRef ref, PackageEntity pkg, String status, String label, Color color) {
    final isSelected = pkg.status == status;
    return Expanded(
      child: GestureDetector(
        onTap: isSelected ? null : () async {
          Navigator.pop(context);
          try {
            await ref.read(packageRepositoryProvider).updatePackageField(pkg.id, {'status': status});
            ref.invalidate(packagesProvider);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('변경에 실패했습니다. 다시 시도해주세요.'), backgroundColor: AppTheme.errorColor),
              );
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active': return AppTheme.primaryColor;
      case 'completed': return Colors.blue;
      case 'expired': return Colors.orange;
      case 'cancelled': return Colors.grey;
      default: return Colors.grey;
    }
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case 'paid': return AppTheme.primaryColor;
      case 'partial': return Colors.orange;
      case 'pending': return Colors.red;
      default: return Colors.grey;
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

  Future<void> _showAddPackageDialog(BuildContext context, WidgetRef ref) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final repo = ref.read(studentRepositoryProvider);
      final students = await repo.getStudents(user.id);
      if (!context.mounted) return;

      if (students.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('먼저 학생을 등록해주세요'), backgroundColor: AppTheme.warningColor),
        );
        return;
      }
      _showPackageForm(context, ref, students);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일시적인 오류가 발생했습니다. 다시 시도해주세요.'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  void _showPackageForm(BuildContext context, WidgetRef ref, List<StudentEntity> students) async {
    // 프로필에서 기본 레슨비 조회
    String defaultPrice = '';
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('pro_monthly_fee')
            .eq('id', userId)
            .single();
        final fee = profile['pro_monthly_fee'] as num?;
        if (fee != null) defaultPrice = fee.toInt().toString();
      }
    } catch (_) {}

    if (!context.mounted) return;

    String? selectedStudentId;
    final nameController = TextEditingController(text: '레슨 10회권');
    final countController = TextEditingController(text: '10');
    final priceController = TextEditingController(text: defaultPrice);
    String paymentStatus = 'pending';
    String? paymentMethod;

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
                    Text('레슨 패키지 등록', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.h),

                    // 학생 선택
                    DropdownButtonFormField<String>(
                      value: selectedStudentId,
                      hint: const Text('학생 선택'),
                      items: students.map((s) {
                        return DropdownMenuItem(value: s.id, child: Text(s.studentName));
                      }).toList(),
                      onChanged: (v) => setState(() => selectedStudentId = v),
                      decoration: InputDecoration(
                        labelText: '학생 *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // 패키지명
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '패키지명',
                        hintText: '예: 레슨 10회권',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // 횟수 & 금액
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: countController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '총 횟수 *',
                              suffixText: '회',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: '금액 *',
                              prefixText: '₩ ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // 결제 상태 & 결제 방법
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: paymentStatus,
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('미결제')),
                              DropdownMenuItem(value: 'partial', child: Text('부분결제')),
                              DropdownMenuItem(value: 'paid', child: Text('결제완료')),
                            ],
                            onChanged: (v) => setState(() => paymentStatus = v!),
                            decoration: InputDecoration(
                              labelText: '결제 상태',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: paymentMethod,
                            hint: const Text('선택'),
                            items: const [
                              DropdownMenuItem(value: 'cash', child: Text('현금')),
                              DropdownMenuItem(value: 'card', child: Text('카드')),
                              DropdownMenuItem(value: 'transfer', child: Text('이체')),
                            ],
                            onChanged: (v) => setState(() => paymentMethod = v),
                            decoration: InputDecoration(
                              labelText: '결제 방법',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: selectedStudentId == null
                            ? null
                            : () async {
                                final count = int.tryParse(countController.text);
                                final price = int.tryParse(priceController.text);
                                if (count == null || count <= 0 || price == null || price <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('횟수와 금액을 올바르게 입력해주세요'), backgroundColor: AppTheme.warningColor),
                                  );
                                  return;
                                }

                                try {
                                  final user = ref.read(currentUserProvider);
                                  await ref.read(packageRepositoryProvider).createPackage(
                                    proId: user!.id,
                                    studentId: selectedStudentId!,
                                    packageName: nameController.text.isEmpty ? '레슨 ${count}회권' : nameController.text,
                                    totalCount: count,
                                    price: price,
                                    paymentStatus: paymentStatus,
                                    paymentMethod: paymentMethod,
                                  );

                                  ref.invalidate(packagesProvider);

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('패키지가 등록되었습니다'),
                                        backgroundColor: AppTheme.primaryColor,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('일시적인 오류가 발생했습니다. 다시 시도해주세요.'), backgroundColor: AppTheme.errorColor),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('패키지 등록', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
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
