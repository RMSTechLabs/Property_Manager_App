import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:property_manager_app/src/presentation/screens/home_screen.dart';
import 'package:property_manager_app/src/presentation/screens/splash_screen.dart';
import '../../presentation/providers/auth_state_provider.dart';


final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isInitialized = authState.isInitialized;
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/splash';

      // Show splash while initializing
      if (!isInitialized || isLoading) {
        if (!isSplashRoute) {
          return '/splash';
        }
        return null;
      }

      // After initialization, redirect based on auth state
      if (!isAuthenticated && !isLoginRoute && !isSplashRoute) {
        return '/login';
      }

      if (isAuthenticated && (isLoginRoute || isSplashRoute)) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // GoRoute(
      //   path: '/login',
      //   builder: (context, state) => const LoginScreen(),
      // ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});