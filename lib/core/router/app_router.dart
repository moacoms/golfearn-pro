import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/student_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/find_pro_page.dart';
import '../../features/students/presentation/pages/students_list_page.dart';
import '../../features/students/presentation/pages/student_detail_page.dart';
import '../../features/students/presentation/pages/student_form_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/packages/presentation/pages/packages_page.dart';
import '../../features/lessons/presentation/pages/lessons_page.dart';
import '../../features/income/presentation/pages/income_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../shared/widgets/main_scaffold.dart';

/// 라우터 프로바이더
final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
                         state.matchedLocation == '/register';
      final isSplashRoute = state.matchedLocation == '/';

      // OAuth 콜백 파라미터 처리 (Kakao 로그인 등)
      // supabase_flutter가 먼저 code를 세션으로 교환하므로,
      // 이 시점에는 isAuthenticated가 이미 true일 수 있음.
      final hasOAuthCallback =
          state.uri.queryParameters.containsKey('code') ||
              state.uri.queryParameters.containsKey('error');
      if (hasOAuthCallback) {
        // 이미 세션 생성됨 → 홈으로 (역할 기반 라우팅은 이후 단계에서)
        if (isAuthenticated) {
          return '/home';
        }
        // 아직 세션이 안 붙었거나 에러 → 로그인 페이지
        return '/login';
      }

      // 스플래시 화면은 항상 허용
      if (isSplashRoute) {
        return null;
      }

      // 로그인하지 않은 경우 로그인 페이지로
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // 로그인한 경우 인증 페이지 접근 시 홈으로
      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      // 역할 기반 접근 제어: 프로 전용 라우트
      if (isAuthenticated) {
        const proOnlyRoutes = ['/students', '/income', '/packages'];
        final isProOnlyRoute = proOnlyRoutes.any(
          (route) => state.matchedLocation.startsWith(route),
        );
        if (isProOnlyRoute && !ref.read(isLessonProProvider)) {
          return '/home';
        }

        // 학생 전용 라우트
        const studentOnlyRoutes = ['/find-pro'];
        final isStudentOnlyRoute = studentOnlyRoutes.any(
          (route) => state.matchedLocation.startsWith(route),
        );
        if (isStudentOnlyRoute && ref.read(isLessonProProvider)) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      // 스플래시 화면
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashPage(),
        ),
      ),
      
      // 로그인
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      
      // 회원가입
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterPage(),
        ),
      ),
      
      // 메인 화면 (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // 홈 (대시보드 - 프로/학생 구분)
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) {
              final isLessonPro = ref.read(isLessonProProvider);
              return MaterialPage(
                key: state.pageKey,
                child: isLessonPro ? const DashboardPage() : const StudentDashboardPage(),
              );
            },
          ),
          
          // 학생 관리
          GoRoute(
            path: '/students',
            name: 'students',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const StudentsListPage(),
            ),
            routes: [
              // 학생 추가 (new를 :id 앞에 배치)
              GoRoute(
                path: 'new',
                name: 'student-new',
                pageBuilder: (context, state) => MaterialPage(
                  key: state.pageKey,
                  child: const StudentFormPage(),
                ),
              ),
              // 학생 상세
              GoRoute(
                path: ':id',
                name: 'student-detail',
                pageBuilder: (context, state) {
                  final studentId = state.pathParameters['id']!;
                  return MaterialPage(
                    key: state.pageKey,
                    child: StudentDetailPage(studentId: studentId),
                  );
                },
              ),
            ],
          ),
          
          // 스케줄
          GoRoute(
            path: '/schedule',
            name: 'schedule',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const SchedulePage(),
            ),
          ),
          
          // 레슨 노트
          GoRoute(
            path: '/lessons',
            name: 'lessons',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const LessonsPage(),
            ),
          ),
          
          // 수입 관리
          GoRoute(
            path: '/income',
            name: 'income',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const IncomePage(),
            ),
          ),

          // 패키지 관리
          GoRoute(
            path: '/packages',
            name: 'packages',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const PackagesPage(),
            ),
          ),

          // 레슨프로 찾기
          GoRoute(
            path: '/find-pro',
            name: 'find-pro',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const FindProPage(),
            ),
          ),

          // 설정
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );
});

