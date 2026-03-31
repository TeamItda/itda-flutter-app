import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shell/main_shell.dart';
import '../home/view/home_view.dart';
import '../facility/view/facility_list_view.dart';
import '../facility/view/facility_detail_view.dart';
import '../auth/view/splash_view.dart';   // 추가
import '../auth/view/login_view.dart';    // 추가
import '../auth/view/signup_view.dart';   // 추가

final appRouter = GoRouter(
  initialLocation: '/splash',  // /home → /splash 변경
  routes: [
    // 인증 화면 (추가된 부분)
    GoRoute(path: '/splash', builder: (c, s) => const SplashView()),
    GoRoute(path: '/login', builder: (c, s) => const LoginView()),
    GoRoute(path: '/signup', builder: (c, s) => const SignupView()),
    // 메인 탭 (BottomNavigationBar)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (c, s) => const HomeView()),
        GoRoute(path: '/chat', builder: (c, s) => const Scaffold(body: Center(child: Text('AI 챗봇 - 팀원 E')))),
        GoRoute(path: '/map', builder: (c, s) => const Scaffold(body: Center(child: Text('지도 - 팀원 C')))),
        GoRoute(path: '/favorites', builder: (c, s) => const Scaffold(body: Center(child: Text('즐겨찾기 - 팀원 D')))),
        GoRoute(path: '/profile', builder: (c, s) => const Scaffold(body: Center(child: Text('프로필 - 팀원 D')))),
      ],
    ),
    // 상세 화면 (탭바 없음)
    GoRoute(
      path: '/facilities/:category',
      builder: (c, s) => FacilityListView(categoryId: s.pathParameters['category']!),
    ),
    GoRoute(
      path: '/facility/:id',
      builder: (c, s) => FacilityDetailView(
        facilityId: s.pathParameters['id']!,
        categoryId: s.uri.queryParameters['category'] ?? 'medical',
      ),
    ),
    GoRoute(path: '/search', builder: (c, s) => const Scaffold(body: Center(child: Text('검색 - 팀원 D')))),
  ],
);