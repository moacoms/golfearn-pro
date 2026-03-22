import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
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
    NavItem(icon: Icons.dashboard, label: '홈', route: '/home'),
    NavItem(icon: Icons.people, label: '학생관리', route: '/students'),
    NavItem(icon: Icons.calendar_today, label: '스케줄', route: '/schedule'),
    NavItem(icon: Icons.note, label: '레슨노트', route: '/lessons'),
    NavItem(icon: Icons.inventory_2, label: '패키지', route: '/packages'),
    NavItem(icon: Icons.settings, label: '설정', route: '/settings'),
  ];

  // 학생용 네비
  final List<NavItem> _studentNavItems = [
    NavItem(icon: Icons.dashboard, label: '홈', route: '/home'),
    NavItem(icon: Icons.calendar_today, label: '내 레슨', route: '/schedule'),
    NavItem(icon: Icons.note, label: '레슨노트', route: '/lessons'),
    NavItem(icon: Icons.settings, label: '설정', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isLessonPro = ref.watch(isLessonProProvider);

    // 레슨프로가 아닌 경우: 학생(일반회원)으로 처리
    // 프로필이 없거나 isStudent=false여도 레슨프로가 아니면 학생 화면 표시

    final navItems = isLessonPro ? _proNavItems : _studentNavItems;

    // 현재 위치에 따른 선택된 인덱스 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).uri.path;
      final index = navItems.indexWhere((item) => item.route == location);
      if (index != -1 && index != _selectedIndex) {
        setState(() {
          _selectedIndex = index;
        });
      }
    });

    // selectedIndex가 현재 navItems 범위를 벗어나지 않도록
    final safeIndex = _selectedIndex < navItems.length ? _selectedIndex : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Golfearn Pro',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              print('로그아웃 버튼 클릭됨');
              try {
                print('로그아웃 시작');
                
                // 1. Supabase 직접 로그아웃
                await Supabase.instance.client.auth.signOut();
                print('Supabase 로그아웃 완료');
                
                // 2. AuthController 상태 초기화
                ref.read(authControllerProvider.notifier).state = const AuthState();
                print('AuthController 상태 초기화');
                
                // 3. 모든 관련 Provider 무효화
                ref.invalidate(authControllerProvider);
                ref.invalidate(currentUserProvider);
                ref.invalidate(isAuthenticatedProvider);
                ref.invalidate(authRepositoryProvider);
                print('Provider들 무효화 완료');
                
                // 4. 강제 상태 업데이트를 위한 약간의 지연
                await Future.delayed(const Duration(milliseconds: 100));
                
                if (context.mounted) {
                  print('로그인 페이지로 이동');
                  context.go('/login');
                }
              } catch (e) {
                print('로그아웃 에러: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('로그아웃 실패: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: safeIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          context.go(navItems[index].route);
        },
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        items: navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon, size: 24.w),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLessonProRegistration(BuildContext context, WidgetRef ref, dynamic currentUser) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_golf,
                size: 64.w,
                color: const Color(0xFF10B981),
              ),
              SizedBox(height: 24.h),
              Text(
                '레슨프로 전용 앱입니다',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '이 앱은 골프 레슨프로를 위한 CRM 시스템입니다.\n아래 버튼을 눌러 레슨프로로 등록하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Supabase profiles 테이블에서 is_lesson_pro = true로 업데이트
                      final userId = Supabase.instance.client.auth.currentUser?.id;
                      if (userId == null) return;

                      await Supabase.instance.client
                          .from('profiles')
                          .update({'is_lesson_pro': true})
                          .eq('id', userId);

                      // 상태 새로고침 - authController를 무효화하여 프로필 다시 로드
                      ref.invalidate(authControllerProvider);
                      ref.invalidate(currentUserProvider);
                      ref.invalidate(isLessonProProvider);

                      // 인증 상태를 다시 로드하기 위해 로그인 다시 트리거
                      final profile = await Supabase.instance.client
                          .from('profiles')
                          .select()
                          .eq('id', userId)
                          .single();

                      // AuthController 상태를 업데이트된 프로필로 갱신
                      final user = currentUser;
                      if (user != null) {
                        ref.read(authControllerProvider.notifier).state = AuthState(
                          user: user.copyWith(isLessonPro: true),
                        );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('레슨프로로 등록되었습니다!'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('등록 실패: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '레슨프로로 등록하기',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  ref.invalidate(authControllerProvider);
                  if (context.mounted) context.go('/login');
                },
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;

  NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}