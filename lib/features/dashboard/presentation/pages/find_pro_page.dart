import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 레슨프로 목록 프로바이더
final lessonProsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('is_lesson_pro', true)
      .order('full_name', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

class FindProPage extends ConsumerWidget {
  const FindProPage({super.key});

  static const _primary = Color(0xFF10B981);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prosAsync = ref.watch(lessonProsProvider);

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

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(lessonProsProvider),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: pros.length,
              itemBuilder: (context, index) {
                return _buildProCard(context, pros[index]);
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

  Widget _buildProCard(BuildContext context, Map<String, dynamic> pro) {
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
        child: Row(
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
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
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
