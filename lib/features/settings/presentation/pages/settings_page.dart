import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/domain/entities/user_entity.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  static const _kDefaultDurationKey = 'default_lesson_duration';
  static const _kDefaultPriceKey = 'default_lesson_price';

  int _defaultDuration = 60;
  String _defaultPrice = '';
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
      _defaultPrice = prefs.getString(_kDefaultPriceKey) ?? '';
      _isLoadingPrefs = false;
    });
  }

  Future<void> _saveDuration(int duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDefaultDurationKey, duration);
    setState(() => _defaultDuration = duration);
  }

  Future<void> _savePrice(String price) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultPriceKey, price);
    setState(() => _defaultPrice = price);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

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
                SizedBox(height: 24.h),
                _buildSectionLabel('앱 설정'),
                SizedBox(height: 8.h),
                _buildAppSettingsCard(),
                SizedBox(height: 24.h),
                _buildSectionLabel('데이터'),
                SizedBox(height: 8.h),
                _buildDataCard(),
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
            backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF10B981),
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
                foregroundColor: const Color(0xFF10B981),
                side: const BorderSide(color: Color(0xFF10B981)),
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
              color: const Color(0xFF10B981),
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
        // Default lesson price
        _settingsTile(
          icon: Icons.monetization_on_outlined,
          title: '기본 레슨 가격',
          trailing: SizedBox(
            width: 120.w,
            child: TextField(
              controller: TextEditingController(text: _defaultPrice),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFFD1D5DB),
                ),
                suffixText: '원',
                suffixStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onSubmitted: _savePrice,
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
              },
            ),
          ),
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
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('준비 중입니다'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: const Color(0xFF374151),
              ),
            );
          },
        ),
      ],
    );
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
                color: (iconColor ?? const Color(0xFF10B981)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: iconColor ?? const Color(0xFF10B981),
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
  void _showEditProfileDialog(UserEntity? user) {
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final phoneController =
        TextEditingController(text: user?.phoneNumber ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
        contentPadding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
        actionsPadding: EdgeInsets.all(16.w),
        title: Text(
          '프로필 수정',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 14.h),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '전화번호',
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ],
          ),
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
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop();
              try {
                await ref
                    .read(authControllerProvider.notifier)
                    .updateProfile(
                      fullName: nameController.text.trim(),
                      phoneNumber: phoneController.text.trim().isNotEmpty
                          ? phoneController.text.trim()
                          : null,
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('프로필이 업데이트되었습니다'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('프로필 업데이트 실패: $e'),
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
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              '저장',
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
