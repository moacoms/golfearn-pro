import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../core/constants/sport_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  // 레슨프로용 네비
  final List<NavItem> _proNavItems = [
    NavItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, label: '홈', route: '/home'),
    NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: '학생', route: '/students'),
    NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: '스케줄', route: '/schedule'),
    NavItem(icon: Icons.edit_note_outlined, activeIcon: Icons.edit_note_rounded, label: '노트', route: '/lessons'),
    NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2_rounded, label: '패키지', route: '/packages'),
    NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: '설정', route: '/settings'),
  ];

  // 학생용 네비
  final List<NavItem> _studentNavItems = [
    NavItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, label: '홈', route: '/home'),
    NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: '내 레슨', route: '/schedule'),
    NavItem(icon: Icons.edit_note_outlined, activeIcon: Icons.edit_note_rounded, label: '노트', route: '/lessons'),
    NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: '설정', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isLessonPro = ref.watch(isLessonProProvider);
    final navItems = isLessonPro ? _proNavItems : _studentNavItems;

    // 현재 위치에 따른 선택된 인덱스 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).uri.path;
      final index = navItems.indexWhere((item) => item.route == location);
      if (index != -1 && index != _selectedIndex) {
        setState(() => _selectedIndex = index);
      }
    });

    final safeIndex = _selectedIndex < navItems.length ? _selectedIndex : 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: widget.child,
      extendBody: true,
      bottomNavigationBar: _buildFloatingBottomNav(navItems, safeIndex),
    );
  }

  Widget _buildFloatingBottomNav(List<NavItem> navItems, int safeIndex) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppTheme.bottomNavShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = index == safeIndex;
              return _buildNavItem(item, isSelected, index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        context.go(item.route);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 10.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 22.w,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
            ),
            SizedBox(height: 2.h),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
                fontFamily: 'Noto Sans KR',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
