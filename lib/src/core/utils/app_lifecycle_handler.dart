import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_state_provider.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  final Ref ref;

  AppLifecycleHandler(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        // App went to background
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        _handleAppDetached();
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., incoming call)
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  void _handleAppResumed() {
    print('App resumed - checking auth state');
    
    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated) {
      // Force refresh token when app resumes
      ref.read(authStateProvider.notifier).forceRefreshToken();
    }
  }

  void _handleAppPaused() {
    print('App paused - auth state preserved');
    // Don't logout when app goes to background
    // Token refresh will continue in background if possible
  }

  void _handleAppDetached() {
    print('App detached - auth state preserved');
    // Don't logout when app is terminated
    // User will remain logged in for next app launch
  }
}

// Provider for app lifecycle
final appLifecycleProvider = Provider<AppLifecycleHandler>((ref) {
  return AppLifecycleHandler(ref);
});