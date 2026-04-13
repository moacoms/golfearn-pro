import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

// ──────────────────────────────────────────────
// Constants
// ──────────────────────────────────────────────

const _proGrades = <String, String>{
  'semi_pro': '세미프로',
  'lesson_pro': '레슨프로',
  'kpga_associate': 'KPGA 준회원',
  'kpga_member': 'KPGA 정회원',
  'tour_pro': '투어프로',
};

const _experienceRanges = <String, String>{
  'all': '전체',
  '1-3': '1~3년',
  '3-5': '3~5년',
  '5-10': '5~10년',
  '10+': '10년 이상',
};

// ──────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────

/// 레슨프로 목록
final lessonProsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('is_lesson_pro', true)
      .order('full_name', ascending: true);
  return List<Map<String, dynamic>>.from(response);
});

/// 연결된 프로 ID
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

// ──────────────────────────────────────────────
// Page
// ──────────────────────────────────────────────

class FindProPage extends ConsumerStatefulWidget {
  const FindProPage({super.key});

  @override
  ConsumerState<FindProPage> createState() => _FindProPageState();
}

class _FindProPageState extends ConsumerState<FindProPage> {
  static const _primary = AppTheme.primaryColor;

  String _searchQuery = '';
  String _selectedLocation = '전체';
  String _selectedExperience = 'all';

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
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
                  Text('등록된 레슨프로가 없습니다', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                ],
              ),
            );
          }

          final connectedIds = connectedIdsAsync.when(
            data: (ids) => ids,
            loading: () => <String>{},
            error: (_, __) => <String>{},
          );

          // 지역 목록 동적 추출
          final locations = <String>{'전체'};
          for (final p in pros) {
            final loc = p['pro_location'] as String?;
            if (loc != null && loc.trim().isNotEmpty) locations.add(loc.trim());
          }

          // 필터 적용
          final filtered = _applyFilters(pros);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(lessonProsProvider);
              ref.invalidate(connectedProIdsProvider);
            },
            child: Column(
              children: [
                // 검색바
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: '이름, 지역, 장소로 검색',
                      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                // 지역 필터
                Container(
                  color: Colors.white,
                  height: 44.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: locations.map((loc) {
                      final selected = _selectedLocation == loc;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: Text(loc, style: TextStyle(fontSize: 12.sp, color: selected ? Colors.white : Colors.grey[700])),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedLocation = loc),
                          selectedColor: _primary,
                          backgroundColor: Colors.grey[100],
                          side: BorderSide.none,
                          labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // 경력 필터
                Container(
                  color: Colors.white,
                  height: 44.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: _experienceRanges.entries.map((e) {
                      final selected = _selectedExperience == e.key;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ChoiceChip(
                          label: Text(e.value, style: TextStyle(fontSize: 12.sp, color: selected ? Colors.white : Colors.grey[700])),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedExperience = e.key),
                          selectedColor: _primary,
                          backgroundColor: Colors.grey[100],
                          side: BorderSide.none,
                          labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 4.h),
                // 결과 수
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${filtered.length}명의 프로',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[500], fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                // 프로 목록
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text('검색 결과가 없습니다', style: TextStyle(fontSize: 14.sp, color: Colors.grey[400])),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final pro = filtered[index];
                            final proId = pro['id'] as String;
                            final isConnected = connectedIds.contains(proId);
                            return _buildProCard(context, pro, isConnected: isConnected, showRequestButton: isStudent);
                          },
                        ),
                ),
              ],
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
              TextButton(onPressed: () => ref.invalidate(lessonProsProvider), child: const Text('다시 시도')),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Filter Logic
  // ──────────────────────────────────────────────

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> pros) {
    return pros.where((pro) {
      // 텍스트 검색
      if (_searchQuery.isNotEmpty) {
        final name = (pro['full_name'] as String? ?? '').toLowerCase();
        final location = (pro['pro_location'] as String? ?? '').toLowerCase();
        final intro = (pro['pro_introduction'] as String? ?? '').toLowerCase();
        final venues = (pro['pro_lesson_venues'] as List?)?.join(' ').toLowerCase() ?? '';
        if (!name.contains(_searchQuery) &&
            !location.contains(_searchQuery) &&
            !intro.contains(_searchQuery) &&
            !venues.contains(_searchQuery)) {
          return false;
        }
      }

      // 지역 필터
      if (_selectedLocation != '전체') {
        final loc = (pro['pro_location'] as String? ?? '').trim();
        if (loc != _selectedLocation) return false;
      }

      // 경력 필터
      if (_selectedExperience != 'all') {
        final exp = pro['pro_experience_years'] as int? ?? 0;
        switch (_selectedExperience) {
          case '1-3':
            if (exp < 1 || exp > 3) return false;
          case '3-5':
            if (exp < 3 || exp > 5) return false;
          case '5-10':
            if (exp < 5 || exp > 10) return false;
          case '10+':
            if (exp < 10) return false;
        }
      }

      return true;
    }).toList();
  }

  // ──────────────────────────────────────────────
  // Pro Card
  // ──────────────────────────────────────────────

  Widget _buildProCard(
    BuildContext context,
    Map<String, dynamic> pro, {
    required bool isConnected,
    required bool showRequestButton,
  }) {
    final name = pro['full_name'] as String? ?? '이름 없음';
    final experience = pro['pro_experience_years'] as int?;
    final location = pro['pro_location'] as String? ?? '';
    final intro = pro['pro_introduction'] as String? ?? '';
    final grade = pro['pro_grade'] as String?;
    final venues = (pro['pro_lesson_venues'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final gradeLabel = grade != null ? _proGrades[grade] : null;

    return GestureDetector(
      onTap: () => _showProDetailDialog(context, pro, isConnected: isConnected, showRequestButton: showRequestButton),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: _primary.withValues(alpha: 0.12),
                    child: Text(initial, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: _primary)),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이름 + 등급 배지
                        Row(
                          children: [
                            Flexible(
                              child: Text(name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
                            ),
                            if (gradeLabel != null) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: _gradeColor(grade!).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(gradeLabel, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: _gradeColor(grade))),
                              ),
                            ],
                            if (isConnected) ...[
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                                child: Text('연결됨', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.blue)),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 6.h),
                        // 경력 + 지역
                        if (experience != null || location.isNotEmpty)
                          _buildInfoRow(
                            Icons.work_outline,
                            [
                              if (experience != null) '경력 $experience년',
                              if (location.isNotEmpty) location,
                            ].join(' · '),
                          ),
                        // 레슨 장소
                        if (venues.isNotEmpty)
                          _buildInfoRow(Icons.location_on_outlined, venues.join(', ')),
                        // 소개
                        if (intro.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(intro, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20.w, color: Colors.grey[300]),
                ],
              ),
              if (showRequestButton && !isConnected) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _requestConnection(context, pro),
                    icon: Icon(Icons.person_add, size: 18.w),
                    label: Text('레슨 신청', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'tour_pro':
      case 'kpga_member':
        return const Color(0xFFD97706);
      case 'kpga_associate':
        return const Color(0xFF059669);
      default:
        return _primary;
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        children: [
          Icon(icon, size: 14.w, color: Colors.grey[500]),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Pro Detail Dialog
  // ──────────────────────────────────────────────

  void _showProDetailDialog(
    BuildContext context,
    Map<String, dynamic> pro, {
    required bool isConnected,
    required bool showRequestButton,
  }) {
    final name = pro['full_name'] as String? ?? '이름 없음';
    final phone = pro['pro_phone'] as String? ?? '';
    final intro = pro['pro_introduction'] as String? ?? '';
    final experience = pro['pro_experience_years'] as int?;
    final location = pro['pro_location'] as String? ?? '';
    final grade = pro['pro_grade'] as String?;
    final gradeLabel = grade != null ? _proGrades[grade] : null;
    final venues = (pro['pro_lesson_venues'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final specialties = (pro['pro_specialties'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final cert = pro['pro_certification'] as String? ?? '';
    final fee = pro['pro_monthly_fee'] as num?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아바타
              CircleAvatar(
                radius: 36.r,
                backgroundColor: _primary.withValues(alpha: 0.12),
                child: Text(initial, style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold, color: _primary)),
              ),
              SizedBox(height: 12.h),
              // 이름 + 등급
              Text(name, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              if (gradeLabel != null) ...[
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _gradeColor(grade!).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(gradeLabel, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _gradeColor(grade))),
                ),
              ],
              SizedBox(height: 16.h),

              // 정보 목록
              if (experience != null)
                _detailRow(Icons.work_outline, '경력', '$experience년'),
              if (location.isNotEmpty)
                _detailRow(Icons.map_outlined, '지역', location),
              if (venues.isNotEmpty)
                _detailRow(Icons.location_on_outlined, '레슨 장소', venues.join('\n')),
              if (cert.isNotEmpty)
                _detailRow(Icons.verified_outlined, '자격증', cert),
              if (fee != null)
                _detailRow(Icons.payments_outlined, '레슨비', _formatPrice(fee.toInt())),
              if (phone.isNotEmpty)
                _detailRow(Icons.phone_outlined, '연락처', phone),

              // 전문분야
              if (specialties.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('전문분야', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                ),
                SizedBox(height: 6.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: specialties.map((s) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(s, style: TextStyle(fontSize: 12.sp, color: _primary, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ),
              ],

              // 소개글
              if (intro.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('소개', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                ),
                SizedBox(height: 6.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(intro, style: TextStyle(fontSize: 14.sp, color: Colors.grey[700], height: 1.5)),
                ),
              ],

              SizedBox(height: 20.h),

              // 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text('닫기', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                    ),
                  ),
                  if (showRequestButton && !isConnected) ...[
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _requestConnection(context, pro);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: Text('레슨 신청', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '${buffer}원';
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.w, color: _primary),
          SizedBox(width: 10.w),
          SizedBox(
            width: 60.w,
            child: Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Request Connection
  // ──────────────────────────────────────────────

  Future<void> _requestConnection(BuildContext context, Map<String, dynamic> pro) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final proId = pro['id'] as String;
    final proName = pro['full_name'] as String? ?? '레슨프로';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('레슨 신청', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
        content: Text(
          '$proName 프로에게 레슨을 신청하시겠습니까?\n\n신청 후 프로가 회원님의 정보를 확인할 수 있습니다.',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('취소', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('신청하기', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

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
          SnackBar(content: Text('$proName 프로에게 레슨을 신청했습니다!'), backgroundColor: _primary),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('레슨 신청에 실패했습니다. 다시 시도해주세요.'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
