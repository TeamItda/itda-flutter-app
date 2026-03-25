import 'package:go_router/go_router.dart';
import '../shell/main_shell.dart';
import '../auth/view/splash_view.dart';
import '../auth/view/login_view.dart';
import '../auth/view/signup_view.dart';
import '../home/view/home_view.dart';
import '../chat/view/chat_view.dart';
import '../map/view/map_view.dart';
import '../favorite/view/favorite_view.dart';
import '../profile/view/profile_view.dart';
import '../profile/view/language_setting_view.dart';
import '../profile/view/my_reviews_view.dart';
import '../profile/view/app_info_view.dart';
import '../facility/view/facility_list_view.dart';
import '../facility/view/facility_detail_view.dart';
import '../non_payment/view/non_payment_view.dart';
import '../review/view/review_write_view.dart';
import '../search/view/search_view.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (c, s) => const SplashView()),
    GoRoute(path: '/login', builder: (c, s) => const LoginView()),
    GoRoute(path: '/signup', builder: (c, s) => const SignupView()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (c, s) => const HomeView()),
        GoRoute(path: '/chat', builder: (c, s) => const ChatView()),
        GoRoute(path: '/map', builder: (c, s) => const MapView()),
        GoRoute(path: '/favorites', builder: (c, s) => const FavoriteView()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileView()),
      ],
    ),
    GoRoute(path: '/facilities/:category', builder: (c, s) => FacilityListView(category: s.pathParameters['category']!)),
    GoRoute(path: '/facility/:id', builder: (c, s) => FacilityDetailView(facilityId: s.pathParameters['id']!)),
    GoRoute(path: '/non-payment/:hospitalId', builder: (c, s) => NonPaymentView(hospitalId: s.pathParameters['hospitalId']!)),
    GoRoute(path: '/review/write/:facilityId', builder: (c, s) => ReviewWriteView(facilityId: s.pathParameters['facilityId']!)),
    GoRoute(path: '/search', builder: (c, s) => const SearchView()),
    GoRoute(path: '/settings/language', builder: (c, s) => const LanguageSettingView()),
    GoRoute(path: '/settings/my-reviews', builder: (c, s) => const MyReviewsView()),
    GoRoute(path: '/settings/app-info', builder: (c, s) => const AppInfoView()),
  ],
);
