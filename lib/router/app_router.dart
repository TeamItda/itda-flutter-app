import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/view/login_view.dart';
import '../auth/view/signup_view.dart';
import '../auth/view/splash_view.dart';
import '../chat/view/chat_view.dart';
import '../facility/view/facility_detail_view.dart';
import '../facility/view/facility_list_view.dart';
import '../favorite/view/favorite_view.dart';
import '../home/view/home_view.dart';
import '../profile/view/profile_view.dart';
import '../search/view/search_view.dart';
import '../shell/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashView()),
    GoRoute(path: '/login', builder: (context, state) => const LoginView()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupView()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeView()),
        GoRoute(path: '/chat', builder: (context, state) => const ChatView()),
        GoRoute(
          path: '/map',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('지도 - 팀원 C'))),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoriteView(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileView(),
        ),
      ],
    ),
    GoRoute(
      path: '/facilities/:category',
      builder: (context, state) =>
          FacilityListView(categoryId: state.pathParameters['category']!),
    ),
    GoRoute(
      path: '/facility/:id',
      builder: (context, state) => FacilityDetailView(
        facilityId: state.pathParameters['id']!,
        categoryId: state.uri.queryParameters['category'] ?? 'medical',
      ),
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchView()),
  ],
);
