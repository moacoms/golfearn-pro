import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../core/utils/download_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/sport_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _kDefaultDurationKey = 'default_lesson_duration';
  int _defaultDuration = 60;
  bool _isLoadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultDuration = prefs.getInt(_kDefaultDurationKey) ?? 60;
      _isLoadingPrefs = false;
    });
  }

  Future<void> _saveDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDefaultDurationKey, duration);
    setState(() => _defaultDuration = duration);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isLessonPro = ref.watch(isLessonProProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text(
          '설정',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: _isLoadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              children: [
                _buildProfileCard(user),
                if (isLessonPro) ...[
                  SizedBox(height: 24.h),
                  _buildSectionLabel('앱 설정'),
                  SizedBox(height: 8.h),
                  _buildAppSettingsCard(),
                  SizedBox(height: 24.h),
                  _buildSectionLabel('데이터'),
                  SizedBox(height: 8.h),
                  _buildDataCard(),
                ],
                SizedBox(height: 24.h),
                _buildSectionLabel('계정'),
                SizedBox(height: 8.h),
                _buildAccountCard(),
                SizedBox(height: 40.h),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Profile Card
  // ---------------------------------------------------------------------------
  Widget _buildProfileCard(UserEntity? user) {
    final name = user?.fullName ?? '이름 없음';
    final email = user?.email ?? '';
    final phone = user?.phoneNumber ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40.r,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 4.h),
          // Email
          Text(
            email,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
          if (phone.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              phone,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditProfileDialog(user),
              icon: Icon(Icons.edit_outlined, size: 18.sp),
              label: Text(
                '프로필 수정',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Label
  // ---------------------------------------------------------------------------
  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9CA3AF),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App Settings Card
  // ---------------------------------------------------------------------------
  Widget _buildAppSettingsCard() {
    return _card(
      children: [
        // 종목 변경은 DB에 sport_type 컬럼 추가 후 활성화
        // Default lesson duration
        _settingsTile(
          icon: Icons.timer_outlined,
          title: '기본 레슨 시간',
          trailing: DropdownButton<int>(
            value: _defaultDuration,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12.r),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
            items: const [
              DropdownMenuItem(value: 30, child: Text('30분')),
              DropdownMenuItem(value: 45, child: Text('45분')),
              DropdownMenuItem(value: 60, child: Text('60분')),
              DropdownMenuItem(value: 90, child: Text('90분')),
            ],
            onChanged: (value) {
              if (value != null) _saveDuration(value);
            },
          ),
        ),
        Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 52.w),
        // Default lesson price — linked to profile
        _settingsTile(
          icon: Icons.monetization_on_outlined,
          title: '기본 레슨 가격',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '프로필에서 설정',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.chevron_right, size: 20.w, color: Colors.grey[400]),
            ],
          ),
          onTap: () => _showEditProfileDialog(ref.read(currentUserProvider)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Data Card
  // ---------------------------------------------------------------------------
  Widget _buildDataCard() {
    return _card(
      children: [
        _settingsTile(
          icon: Icons.file_download_outlined,
          title: '데이터 내보내기',
          trailing: Icon(
            Icons.chevron_right,
            color: const Color(0xFFD1D5DB),
            size: 22.sp,
          ),
          onTap: _showExportDialog,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Export Dialog & Logic
  // ---------------------------------------------------------------------------
  void _showExportDialog() {
    final selections = <String, bool>{
      'students': false,
      'schedules': false,
      'notes': false,
      'packages': false,
      'income': false,
    };
    bool selectAll = false;
    bool isExporting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
          contentPadding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
          actionsPadding: EdgeInsets.all(16.w),
          title: Text(
            '데이터 내보내기',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '내보낼 데이터를 선택해주세요.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 12.h),
              // Select All
              CheckboxListTile(
                value: selectAll,
                activeColor: AppTheme.primaryColor,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '전체 데이터',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                onChanged: (value) {
                  setDialogState(() {
                    selectAll = value ?? false;
                    for (final key in selections.keys) {
                      selections[key] = selectAll;
                    }
                  });
                },
              ),
              Divider(height: 1, color: const Color(0xFFF3F4F6)),
              _exportCheckbox(
                label: '학생 목록',
                value: selections['students']!,
                onChanged: (v) => setDialogState(() {
                  selections['students'] = v ?? false;
                  selectAll = selections.values.every((e) => e);
                }),
              ),
              _exportCheckbox(
                label: '레슨 스케줄',
                value: selections['schedules']!,
                onChanged: (v) => setDialogState(() {
                  selections['schedules'] = v ?? false;
                  selectAll = selections.values.every((e) => e);
                }),
              ),
              _exportCheckbox(
                label: '레슨 노트',
                value: selections['notes']!,
                onChanged: (v) => setDialogState(() {
                  selections['notes'] = v ?? false;
                  selectAll = selections.values.every((e) => e);
                }),
              ),
              _exportCheckbox(
                label: '패키지',
                value: selections['packages']!,
                onChanged: (v) => setDialogState(() {
                  selections['packages'] = v ?? false;
                  selectAll = selections.values.every((e) => e);
                }),
              ),
              _exportCheckbox(
                label: '수입 기록',
                value: selections['income']!,
                onChanged: (v) => setDialogState(() {
                  selections['income'] = v ?? false;
                  selectAll = selections.values.every((e) => e);
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  isExporting ? null : () => Navigator.of(dialogContext).pop(),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isExporting ||
                      !selections.values.any((v) => v)
                  ? null
                  : () async {
                      setDialogState(() => isExporting = true);
                      try {
                        await _exportCsv(Map.from(selections));
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: const Text('데이터가 다운로드되었습니다'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isExporting = false);
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('내보내기 실패: $e'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: isExporting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      '내보내기',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exportCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      activeColor: AppTheme.primaryColor,
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF1F2937),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Future<void> _exportCsv(Map<String, bool> selections) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다');

    final buffer = StringBuffer();

    // Students
    if (selections['students'] == true) {
      final data = await client
          .from('lesson_students')
          .select()
          .eq('pro_id', userId)
          .order('created_at', ascending: false);
      final rows = List<Map<String, dynamic>>.from(data);

      buffer.writeln('=== 학생 목록 ===');
      buffer.writeln('이름,전화번호,이메일,현재 레벨,목표,메모,총 레슨 횟수,활성 여부');
      for (final r in rows) {
        buffer.writeln([
          _csvEscape(r['student_name'] ?? ''),
          _csvEscape(r['student_phone'] ?? ''),
          _csvEscape(r['student_email'] ?? ''),
          _csvEscape(r['current_level'] ?? ''),
          _csvEscape(r['goal'] ?? ''),
          _csvEscape(r['student_memo'] ?? ''),
          r['total_lesson_count'] ?? 0,
          (r['is_active'] == true) ? 'O' : 'X',
        ].join(','));
      }
      buffer.writeln();
    }

    // Schedules
    if (selections['schedules'] == true) {
      final data = await client
          .from('lesson_schedules')
          .select('*, lesson_students(student_name)')
          .eq('pro_id', userId)
          .order('lesson_date', ascending: false);
      final rows = List<Map<String, dynamic>>.from(data);

      buffer.writeln('=== 레슨 스케줄 ===');
      buffer.writeln('날짜,시간,학생명,레슨 유형,소요시간(분),상태,장소,메모');
      for (final r in rows) {
        final studentInfo = r['lesson_students'];
        final studentName = studentInfo is Map
            ? (studentInfo['student_name'] ?? '')
            : '';
        buffer.writeln([
          _csvEscape(r['lesson_date'] ?? ''),
          _csvEscape(r['lesson_time'] ?? ''),
          _csvEscape(studentName),
          _csvEscape(_lessonTypeLabel(r['lesson_type'])),
          r['duration_minutes'] ?? 60,
          _csvEscape(_scheduleStatusLabel(r['status'])),
          _csvEscape(r['location'] ?? ''),
          _csvEscape(r['memo'] ?? ''),
        ].join(','));
      }
      buffer.writeln();
    }

    // Lesson Notes
    if (selections['notes'] == true) {
      final data = await client
          .from('lesson_notes')
          .select('*, lesson_students(student_name)')
          .eq('pro_id', userId)
          .order('created_at', ascending: false);
      final rows = List<Map<String, dynamic>>.from(data);

      buffer.writeln('=== 레슨 노트 ===');
      buffer.writeln('날짜,학생명,레슨내용,개선사항,숙제,다음포커스');
      for (final r in rows) {
        final studentInfo = r['lesson_students'];
        final studentName = studentInfo is Map
            ? (studentInfo['student_name'] ?? '')
            : '';
        final improvements = r['improvements'];
        final improvementsStr = improvements is List ? improvements.join(', ') : '';
        buffer.writeln([
          _csvEscape(r['created_at'] ?? ''),
          _csvEscape(studentName),
          _csvEscape(r['manual_note'] ?? ''),
          _csvEscape(improvementsStr),
          _csvEscape(r['homework'] ?? ''),
          _csvEscape(r['next_focus'] ?? ''),
        ].join(','));
      }
      buffer.writeln();
    }

    // Packages
    if (selections['packages'] == true) {
      final data = await client
          .from('lesson_packages')
          .select('*, lesson_students(student_name)')
          .eq('pro_id', userId)
          .order('created_at', ascending: false);
      final rows = List<Map<String, dynamic>>.from(data);

      buffer.writeln('=== 패키지 ===');
      buffer.writeln('패키지명,학생명,총 횟수,사용 횟수,남은 횟수,가격,상태,결제상태,시작일,종료일');
      for (final r in rows) {
        final studentInfo = r['lesson_students'];
        final studentName = studentInfo is Map
            ? (studentInfo['student_name'] ?? '')
            : '';
        buffer.writeln([
          _csvEscape(r['package_name'] ?? ''),
          _csvEscape(studentName),
          r['total_count'] ?? 0,
          r['used_count'] ?? 0,
          r['remaining_count'] ?? 0,
          r['price'] ?? 0,
          _csvEscape(_packageStatusLabel(r['status'])),
          _csvEscape(_paymentStatusLabel(r['payment_status'])),
          _csvEscape(r['start_date'] ?? ''),
          _csvEscape(r['end_date'] ?? ''),
        ].join(','));
      }
      buffer.writeln();
    }

    // Income Records
    if (selections['income'] == true) {
      final data = await client
          .from('pro_income_records')
          .select()
          .eq('pro_id', userId)
          .order('payment_date', ascending: false);
      final rows = List<Map<String, dynamic>>.from(data);

      buffer.writeln('=== 수입 기록 ===');
      buffer.writeln('날짜,카테고리,금액,결제방법,설명');
      for (final r in rows) {
        buffer.writeln([
          _csvEscape(r['payment_date'] ?? ''),
          _csvEscape(_incomeCategoryLabel(r['income_type'])),
          r['amount'] ?? 0,
          _csvEscape(_paymentMethodLabel(r['payment_method'])),
          _csvEscape(r['memo'] ?? ''),
        ].join(','));
      }
      buffer.writeln();
    }

    _downloadCsv(buffer.toString());
  }

  void _downloadCsv(String csvContent, [String? filename]) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final name = filename ?? 'golfearn_export_$dateStr.csv';
    downloadCsvFile(csvContent, name);
  }

  /// CSV 값 이스케이프: 쉼표, 줄바꿈, 큰따옴표가 있으면 큰따옴표로 감쌈
  String _csvEscape(dynamic value) {
    final str = (value ?? '').toString();
    if (str.contains(',') || str.contains('\n') || str.contains('"')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  String _lessonTypeLabel(String? type) {
    switch (type) {
      case 'regular': return '일반 레슨';
      case 'playing': return '필드 레슨';
      case 'short_game': return '숏게임';
      case 'putting': return '퍼팅';
      default: return type ?? '일반 레슨';
    }
  }

  String _scheduleStatusLabel(String? status) {
    switch (status) {
      case 'scheduled': return '예정';
      case 'completed': return '완료';
      case 'cancelled': return '취소';
      case 'no_show': return '노쇼';
      default: return status ?? '';
    }
  }

  String _packageStatusLabel(String? status) {
    switch (status) {
      case 'active': return '사용중';
      case 'expired': return '만료';
      case 'completed': return '소진';
      case 'cancelled': return '취소';
      default: return status ?? '';
    }
  }

  String _paymentStatusLabel(String? status) {
    switch (status) {
      case 'pending': return '미결제';
      case 'partial': return '부분결제';
      case 'paid': return '결제완료';
      default: return status ?? '';
    }
  }

  String _incomeCategoryLabel(String? category) {
    switch (category) {
      case 'lesson': return '레슨비';
      case 'package': return '패키지';
      case 'other': return '기타';
      default: return category ?? '';
    }
  }

  String _paymentMethodLabel(String? method) {
    switch (method) {
      case 'cash': return '현금';
      case 'card': return '카드';
      case 'transfer': return '계좌이체';
      case 'other': return '기타';
      default: return method ?? '';
    }
  }

  // ---------------------------------------------------------------------------
  // Account Card
  // ---------------------------------------------------------------------------
  Widget _buildAccountCard() {
    return _card(
      children: [
        _settingsTile(
          icon: Icons.logout,
          title: '로그아웃',
          iconColor: const Color(0xFFEF4444),
          titleColor: const Color(0xFFEF4444),
          trailing: const SizedBox.shrink(),
          onTap: _handleLogout,
        ),
        Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 52.w),
        _settingsTile(
          icon: Icons.info_outline,
          title: '앱 버전',
          trailing: Text(
            '1.0.0',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared card wrapper
  // ---------------------------------------------------------------------------
  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ---------------------------------------------------------------------------
  // Settings tile
  // ---------------------------------------------------------------------------
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: iconColor ?? AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? const Color(0xFF1F2937),
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Edit Profile Dialog
  // ---------------------------------------------------------------------------

  static const _proGrades = <String, String>{
    'semi_pro': '세미프로',
    'lesson_pro': '레슨프로',
    'kpga_associate': 'KPGA 준회원',
    'kpga_member': 'KPGA 정회원',
    'tour_pro': '투어프로',
  };

  static const _specialtyOptions = [
    '스윙교정', '숏게임', '퍼팅', '드라이버', '입문자 전문', '주니어 전문',
  ];

  void _showEditProfileDialog(UserEntity? user) async {
    // 프로 전용 필드를 DB에서 직접 조회
    final isLessonPro = user?.isLessonPro ?? false;
    Map<String, dynamic>? proData;
    if (isLessonPro && user != null) {
      try {
        proData = await Supabase.instance.client
            .from('profiles')
            .select('pro_location, pro_introduction, pro_experience_years, pro_specialties, pro_monthly_fee, pro_grade, pro_lesson_venues, pro_certification')
            .eq('id', user.id)
            .single();
      } catch (_) {}
    }

    final nameController = TextEditingController(text: user?.fullName ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final locationController = TextEditingController(text: proData?['pro_location'] as String? ?? '');
    final introController = TextEditingController(text: proData?['pro_introduction'] as String? ?? '');
    final experienceController = TextEditingController(
      text: (proData?['pro_experience_years'] as int?)?.toString() ?? '',
    );
    final feeController = TextEditingController(
      text: (proData?['pro_monthly_fee'] as num?)?.toString() ?? '',
    );
    final venueController = TextEditingController();
    final certController = TextEditingController(text: proData?['pro_certification'] as String? ?? '');

    String? selectedGrade = proData?['pro_grade'] as String?;
    List<String> venues = List<String>.from(
      (proData?['pro_lesson_venues'] as List?)?.map((e) => e.toString()) ?? [],
    );
    List<String> selectedSpecialties = List<String>.from(
      (proData?['pro_specialties'] as List?)?.map((e) => e.toString()) ?? [],
    );

    final formKey = GlobalKey<FormState>();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(dialogContext).size.height * 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 16.w, 0),
                  child: Row(
                    children: [
                      Text('프로필 수정', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey[200]),
                // 폼
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24.w),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField(nameController, '이름', required: true),
                          SizedBox(height: 14.h),
                          _buildFormField(phoneController, '전화번호', keyboardType: TextInputType.phone),

                          if (isLessonPro) ...[
                            SizedBox(height: 20.h),
                            Text('프로 정보', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                            SizedBox(height: 14.h),

                            // 프로 등급
                            DropdownButtonFormField<String>(
                              value: selectedGrade,
                              decoration: _inputDecoration('프로 등급'),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('선택 안함')),
                                ..._proGrades.entries.map((e) =>
                                  DropdownMenuItem(value: e.key, child: Text(e.value)),
                                ),
                              ],
                              onChanged: (v) => setDialogState(() => selectedGrade = v),
                            ),
                            SizedBox(height: 14.h),

                            // 레슨 장소
                            Text('레슨 장소', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                            SizedBox(height: 6.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: venues.map((v) => Chip(
                                label: Text(v, style: TextStyle(fontSize: 13.sp)),
                                deleteIcon: Icon(Icons.close, size: 16.w),
                                onDeleted: () => setDialogState(() => venues.remove(v)),
                                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                side: BorderSide.none,
                              )).toList(),
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: venueController,
                                    decoration: _inputDecoration('장소 입력 (예: 고양CC 인도어)'),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                IconButton(
                                  onPressed: () {
                                    final text = venueController.text.trim();
                                    if (text.isNotEmpty && !venues.contains(text)) {
                                      setDialogState(() => venues.add(text));
                                      venueController.clear();
                                    }
                                  },
                                  icon: Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 28.w),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),

                            _buildFormField(locationController, '레슨 지역 (예: 서울 강남, 경기 고양)'),
                            SizedBox(height: 14.h),
                            _buildFormField(experienceController, '경력 (년)', keyboardType: TextInputType.number),
                            SizedBox(height: 14.h),
                            _buildFormField(certController, '자격증'),
                            SizedBox(height: 14.h),

                            // 전문분야
                            Text('전문분야', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                            SizedBox(height: 6.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              children: _specialtyOptions.map((s) {
                                final selected = selectedSpecialties.contains(s);
                                return FilterChip(
                                  label: Text(s, style: TextStyle(fontSize: 13.sp, color: selected ? Colors.white : Colors.grey[700])),
                                  selected: selected,
                                  onSelected: (v) => setDialogState(() {
                                    if (v) { selectedSpecialties.add(s); } else { selectedSpecialties.remove(s); }
                                  }),
                                  selectedColor: AppTheme.primaryColor,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: Colors.grey[100],
                                  side: BorderSide.none,
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 14.h),

                            _buildFormField(feeController, '레슨비 (만원)', keyboardType: TextInputType.number),
                            SizedBox(height: 14.h),
                            TextFormField(
                              controller: introController,
                              maxLines: 3,
                              decoration: _inputDecoration('소개글'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // 버튼
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.of(dialogContext).pop();

                        final extra = <String, dynamic>{};
                        if (isLessonPro) {
                          extra['pro_location'] = locationController.text.trim().isNotEmpty ? locationController.text.trim() : null;
                          extra['pro_introduction'] = introController.text.trim().isNotEmpty ? introController.text.trim() : null;
                          extra['pro_experience_years'] = experienceController.text.trim().isNotEmpty ? int.tryParse(experienceController.text.trim()) : null;
                          extra['pro_specialties'] = selectedSpecialties.isNotEmpty ? selectedSpecialties : null;
                          extra['pro_monthly_fee'] = feeController.text.trim().isNotEmpty ? num.tryParse(feeController.text.trim()) : null;
                          extra['pro_grade'] = selectedGrade;
                          extra['pro_lesson_venues'] = venues.isNotEmpty ? venues : null;
                          extra['pro_certification'] = certController.text.trim().isNotEmpty ? certController.text.trim() : null;
                        }

                        try {
                          await ref
                              .read(authControllerProvider.notifier)
                              .updateProfile(
                                fullName: nameController.text.trim(),
                                phoneNumber: phoneController.text.trim().isNotEmpty
                                    ? phoneController.text.trim()
                                    : null,
                                extraFields: extra.isNotEmpty ? extra : null,
                              );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('프로필이 업데이트되었습니다'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                backgroundColor: AppTheme.primaryColor,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('프로필 업데이트 실패: $e'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text('저장', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 14.sp),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, {TextInputType? keyboardType, bool required = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label),
      validator: required ? (value) {
        if (value == null || value.trim().isEmpty) return '$label을(를) 입력해주세요';
        return null;
      } : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
          style: TextStyle(fontSize: 14.sp),
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
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              '로그아웃',
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

    try {
      await Supabase.instance.client.auth.signOut();
      ref.read(authControllerProvider.notifier).state = const AuthState();
      ref.invalidate(authControllerProvider);
      ref.invalidate(currentUserProvider);
      ref.invalidate(isAuthenticatedProvider);
      ref.invalidate(authRepositoryProvider);
      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) context.go('/login');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 실패: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }
}
