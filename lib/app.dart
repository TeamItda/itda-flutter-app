import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'auth/viewmodel/auth_viewmodel.dart';
import 'home/viewmodel/home_viewmodel.dart';
import 'chat/viewmodel/chat_viewmodel.dart';
import 'facility/viewmodel/facility_list_viewmodel.dart';
import 'facility/viewmodel/facility_detail_viewmodel.dart';
import 'non_payment/viewmodel/non_payment_viewmodel.dart';
import 'review/viewmodel/review_viewmodel.dart';
import 'search/viewmodel/search_viewmodel.dart';
import 'favorite/viewmodel/favorite_viewmodel.dart';
import 'map/viewmodel/map_viewmodel.dart';
import 'profile/viewmodel/profile_viewmodel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => FacilityListViewModel()),
        ChangeNotifierProvider(create: (_) => FacilityDetailViewModel()),
        ChangeNotifierProvider(create: (_) => NonPaymentViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => FavoriteViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp.router(
        title: '종로 라이프 가이드',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF2563EB),
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
