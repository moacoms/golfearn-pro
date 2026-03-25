import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// 레슨프로 목록 프로바이더
final lessonProsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('is_lesson_pro', true)
      .order('full_name', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

/// 현재 학생이 이미 연결된 프로 ID 목록 프로바이더
final connectedProIdsProvider = FutureProvider<Set<String>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return {};

  final response = await Supabase.instance.client
      .from('lesson_students')
      .select('pro_id')
      .eq('user_id', userId);

  final list = List<Map<String, dynamic>>.from(response);
  return list.map((e) => e['pro_id'] as String).toSet();
});

class FindProPage extends ConsumerWidget {
  const FindProPage({super.key});

  static const _primary = Color(0xFF10B981);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prosAsync = ref.watch(lessonProsProvider);
    final connectedIdsAsync = ref.watch(connectedProIdsProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isStudent = currentUser?.isStudent ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '레슨프로 찾기',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: prosAsync.when(
        data: (pros) {
          if (pros.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64.w, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    '등록된 레슨프로가 없습니다',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          final connectedIds = connectedIdsAsync.when(
            data: (ids) => ids,
            loading: () => <String>{},
            error: (_, __) => <String>{},
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(lessonProsProvider);
              ref.invalidate(connectedProIdsProvider);
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: pros.length,
              itemBuilder: (context, index) {
                final pro = pros[index];
                final proId = pro['id'] as String;
                final isConnected = connectedIds.contains(proId);
                return _buildProCard(
                  context,
                  ref,
                  pro,
                  isConnected: isConnected,
                  showRequestButton: isStudent,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.w, color: Colors.red[300]),
              SizedBox(height: 12.h),
              Text('프로 목록을 불러올 수 없습니다', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => ref.invalidate(lessonProsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestConnection(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> pro,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final proId = pro['id'] as String;
    final proName = pro['full_name'] as String? ?? '레슨프로';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '레슨 신청',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '$proName 프로에게 레슨을 신청하시겠습니까?\n\n신청 후 프로가 회원님의 정보를 확인할 수 있습니다.',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              '취소',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              '신청하기',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await Supabase.instance.client.from('lesson_students').insert({
        'pro_id': proId,
        'user_id': currentUser.id,
        'student_name': currentUser.fullName ?? '이름 없음',
        'student_phone': currentUser.phoneNumber,
        'is_active': true,
      });

      ref.invalidate(connectedProIdsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$proName 프로에게 레슨을 신청했습니다!'),
            backgroundColor: _primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('레슨 신청 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> pro, {
    required bool isConnected,
    required bool showRequestButton,
  }) {
    final name = pro['full_name'] as String? ?? '이름 없음';
    final phone = pro['pro_phone'] as String? ?? '';
    final intro = pro['pro_introduction'] as String? ?? '';
    final experience = pro['pro_experience_years'] as int?;
    final location = pro['pro_location'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 아바타
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: _primary.withOpacity(0.12),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                // 프로 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: _primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '레슨프로',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _primary,
                              ),
                            ),
                          ),
                          if (isConnected) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '이미 연결됨',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // 경력
                      if (experience != null)
                        _buildInfoRow(Icons.work_outline, '경력 $experience년'),
                      // 위치
                      if (location.isNotEmpty)
                        _buildInfoRow(Icons.location_on_outlined, location),
                      // 전화번호
                      if (phone.isNotEmpty)
                        _buildInfoRow(Icons.phone_outlined, phone),
                      // 소개
                      if (intro.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          intro,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            // 레슨 신청 버튼 (학생만 표시, 미연결 시)
            if (showRequestButton && !isConnected) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _requestConnection(context, ref, pro),
                  icon: Icon(Icons.person_add, size: 18.w),
                  label: Text(
                    '레슨 신청',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        children: [
          Icon(icon, size: 14.w, color: Colors.grey[500]),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
