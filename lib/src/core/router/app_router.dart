import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:property_manager_app/src/presentation/screens/create_complaint_screen.dart';
import 'package:property_manager_app/src/presentation/screens/help_desk.dart';
import 'package:property_manager_app/src/presentation/screens/home_screen.dart';
import 'package:property_manager_app/src/presentation/screens/login_screen.dart';
import 'package:property_manager_app/src/presentation/screens/onboarding_screen.dart';
import 'package:property_manager_app/src/presentation/screens/profile_screen.dart';
import 'package:property_manager_app/src/presentation/screens/setting_screen.dart';
import 'package:property_manager_app/src/presentation/screens/splash_screen.dart';
import 'package:property_manager_app/src/presentation/widgets/buttom_tab.dart';
import 'package:property_manager_app/src/presentation/screens/ticket_detail_screen.dart';
import '../../presentation/providers/auth_state_provider.dart';
import '../../presentation/providers/onboarding_provider.dart';

class AuthRefreshNotifier extends ChangeNotifier {
  final Ref ref;

  AuthRefreshNotifier(this.ref) {
    // Listen to authState changes
    ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // final authNotifier = ValueNotifier<AsyncValue<void>>(const AsyncLoading());
  // print("🙄 app router provider");
  // ref.listen(authStateProvider, (_, __) {
  //   authNotifier.value = const AsyncData(null); // Only auth changes matter now
  // });
  final authNotifier = AuthRefreshNotifier(ref); // 👈 Updated
  return GoRouter(
    observers: [routeObserver], // ✅ Register here, not in MaterialApp
    // initialLocation: '/onboarding',
    initialLocation: '/splash',

    refreshListenable: authNotifier,
    debugLogDiagnostics: kDebugMode,
    // redirect: (context, state) {
    //   final authState = ref.read(authStateProvider);
    //   final onboardingComplete = ref.read(onboardingProvider);
    //   final onboardingReady = ref.read(onboardingReadyProvider);

    //   final location = state.matchedLocation;
    //   print(location);
    //   print(authState.isOtpVerified);
    //   // Wait for both onboarding and auth to load
    //   // ⏳ Wait until both onboarding and auth are ready
    //   if (!authState.isInitialized || !onboardingReady) return null;

    //   if (!onboardingComplete) {
    //     return location == '/onboarding' ? null : '/onboarding';
    //   }

    //   if (!authState.isOtpVerified) {
    //     return location == '/login' ? null : '/login';
    //   }

    //   if (location == '/login' || location == '/onboarding') {
    //     return '/home';
    //   }

    //   return null;
    // },
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final onboardingComplete = ref.read(onboardingProvider);
      final onboardingReady = ref.read(onboardingReadyProvider);
      final location = state.matchedLocation;

      // ⏳ While waiting for state to be ready, stay on splash
      if (!authState.isInitialized || !onboardingReady) {
        return location == '/splash' ? null : '/splash';
      }

      // ✅ Onboarding flow
      if (!onboardingComplete) {
        return location == '/onboarding' ? null : '/onboarding';
      }

      // ✅ Auth flow
      if (!authState.isOtpVerified) {
        return location == '/login' ? null : '/login';
      }

      // ✅ Already onboarded and authenticated
      if (location == '/login' ||
          location == '/onboarding' ||
          location == '/splash') {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/help_desk',
        name: 'help_desk',
        builder: (context, _) => const HelpDeskScreen(),
      ),
      GoRoute(
        path: '/ticket/:id',
        name: 'ticketDetail',
        builder: (context, state) {
          final ticketId = state.pathParameters['id']!;
          return TicketDetailScreen(ticketId: ticketId);
        },
      ),
      // GoRoute(
      //   path: 'ticket/:id',
      //   name: 'ticketDetail',
      //   pageBuilder: (context, state) {
      //     final ticketId = state.pathParameters['id']!;
      //     return NoTransitionPage(
      //       child: ProviderScope(
      //         overrides: [ticketIdProvider.overrideWithValue(ticketId)],
      //         child: const TicketDetailScreen(),
      //       ),
      //     );
      //   },
      // ),
      GoRoute(
        path: '/createComplaint',
        name: 'createComplaint',
        builder: (context, _) => const CreateComplaintScreen(),
      ),
      // GoRoute(
      //   path: '/home',
      //   name: 'home',
      //   builder: (context, _) => const HomeScreen(),
      // ),
      //  GoRoute(
      //   path: '/profile',
      //   name: 'profile',
      //   builder: (context, _) => const ProfileScreen(),
      // ),
      // GoRoute(
      //   path: '/settings',
      //   name: 'settings',
      //   builder: (context, _) => const SettingsScreen(),
      // ),
      /// 👇 ShellRoute for Bottom Navigation layout
      ShellRoute(
        builder: (context, state, child) => BottomTab(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, _) => const HomeScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, _) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, _) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
