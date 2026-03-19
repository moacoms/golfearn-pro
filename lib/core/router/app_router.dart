import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/students/presentation/pages/students_list_page.dart';
import '../../features/students/presentation/pages/student_detail_page.dart';
import '../../features/students/presentation/pages/student_form_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/packages/presentation/pages/packages_page.dart';
import '../../features/lessons/presentation/pages/lessons_page.dart';
import '../../features/income/presentation/pages/income_page.dart';
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
      
      print('라우터 리다이렉트: ${state.matchedLocation}, 인증상태: $isAuthenticated');
      
      // OAuth 콜백 파라미터가 있는 경우 제거하고 로그인 페이지로
      if (state.uri.queryParameters.containsKey('code') || 
          state.uri.queryParameters.containsKey('error')) {
        print('OAuth 파라미터 감지, 로그인으로 리다이렉트');
        return '/login';
      }
      
      // 스플래시 화면은 항상 허용
      if (isSplashRoute) {
        print('스플래시 화면 허용');
        return null;
      }
      
      // 로그인하지 않은 경우 로그인 페이지로
      if (!isAuthenticated && !isAuthRoute) {
        print('미인증 사용자, 로그인으로 리다이렉트');
        return '/login';
      }
      
      // 로그인한 경우 인증 페이지 접근 시 홈으로
      if (isAuthenticated && isAuthRoute) {
        print('인증된 사용자가 로그인 페이지 접근, 홈으로 리다이렉트');
        return '/home';
      }
      
      print('리다이렉트 없음');
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
          // 홈 (대시보드)
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const DashboardPage(),
            ),
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
        ],
      ),
    ],
  );
});

