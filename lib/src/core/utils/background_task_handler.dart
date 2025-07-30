import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_state_provider.dart';
import '../constants/app_constants.dart';

class BackgroundTaskHandler {
  static const String _taskName = 'auth_refresh_task';
  static Timer? _backgroundTimer;
  static Timer? _periodicRefreshTimer;
  static bool _isInitialized = false;

  /// Initialize background task handler
  static void initialize(WidgetRef ref) {
    if (_isInitialized) return;
    
    try {
      _registerBackgroundHandler(ref);
      _registerPeriodicRefresh(ref);
      _isInitialized = true;
      
      if (kDebugMode) {
        //print('✅ Background task handler initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        //print('❌ Failed to initialize background task handler: $e');
      }
    }
  }

  /// Register background refresh handler
  static void _registerBackgroundHandler(WidgetRef ref) {
    _backgroundTimer?.cancel();
    
    // Background refresh every 8 minutes as fallback
    _backgroundTimer = Timer.periodic(
      const Duration(minutes: 8),
      (timer) => _handleBackgroundRefresh(ref),
    );
  }

  /// Register periodic refresh (every 9 minutes)
  static void _registerPeriodicRefresh(WidgetRef ref) {
    _periodicRefreshTimer?.cancel();
    
    // Main periodic refresh every 9 minutes
    _periodicRefreshTimer = Timer.periodic(
      AppConstants.refreshInterval, // 9 minutes
      (timer) => _handlePeriodicRefresh(ref),
    );
  }

  /// Handle background token refresh
  static Future<void> _handleBackgroundRefresh(WidgetRef ref) async {
    try {
      final authState = ref.read(authStateProvider);
      
      if (!authState.isAuthenticated) {
        if (kDebugMode) {
          //print('🔄 Background refresh skipped - user not authenticated');
        }
        return;
      }

      if (kDebugMode) {
        //print('🔄 Background token refresh initiated');
      }

      await ref.read(authStateProvider.notifier).forceRefreshToken();
      
      if (kDebugMode) {
        //print('✅ Background token refresh completed');
      }
    } catch (e) {
      if (kDebugMode) {
        //print('❌ Background token refresh failed: $e');
      }
      
      // Schedule retry in 2 minutes on failure
      Timer(const Duration(minutes: 2), () => _handleBackgroundRefresh(ref));
    }
  }

  /// Handle periodic token refresh (main refresh mechanism)
  static Future<void> _handlePeriodicRefresh(WidgetRef ref) async {
    try {
      final authState = ref.read(authStateProvider);
      
      if (!authState.isAuthenticated) {
        if (kDebugMode) {
          //print('🔄 Periodic refresh skipped - user not authenticated');
        }
        return;
      }

      if (kDebugMode) {
        //print('🔄 Periodic token refresh initiated (9-minute cycle)');
      }

      await ref.read(authStateProvider.notifier).forceRefreshToken();
      
      if (kDebugMode) {
        //print('✅ Periodic token refresh completed');
      }
    } catch (e) {
      if (kDebugMode) {
        //print('❌ Periodic token refresh failed: $e');
      }
    }
  }

  /// Force immediate refresh
  static Future<void> forceRefresh(WidgetRef ref) async {
    if (kDebugMode) {
      //print('🔄 Force refresh requested');
    }
    
    await _handlePeriodicRefresh(ref);
  }

  /// Pause background tasks (when app goes to background)
  static void pause() {
    if (kDebugMode) {
      //print('⏸️ Background tasks paused');
    }
    
    // Keep timers running but reduce frequency
    // This ensures tokens stay fresh even in background
  }

  /// Resume background tasks (when app comes to foreground)
  static void resume(WidgetRef ref) {
    if (kDebugMode) {
      //print('▶️ Background tasks resumed');
    }
    
    // Force immediate refresh when app resumes
    forceRefresh(ref);
  }

  /// Stop all background tasks
  static void stop() {
    if (kDebugMode) {
      //print('⏹️ Background tasks stopped');
    }
    
    _backgroundTimer?.cancel();
    _periodicRefreshTimer?.cancel();
    _backgroundTimer = null;
    _periodicRefreshTimer = null;
  }

  /// Dispose all timers and clean up
  static void dispose() {
    stop();
    _isInitialized = false;
    
    if (kDebugMode) {
      //print('🗑️ Background task handler disposed');
    }
  }

  /// Get current task status
  static Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'backgroundTimerActive': _backgroundTimer?.isActive ?? false,
      'periodicTimerActive': _periodicRefreshTimer?.isActive ?? false,
      'backgroundInterval': '8 minutes',
      'periodicInterval': '9 minutes',
    };
  }

  /// Reset timers (useful for testing or configuration changes)
  static void reset(WidgetRef ref) {
    if (kDebugMode) {
      //print('🔄 Resetting background task handler');
    }
    
    dispose();
    initialize(ref);
  }
}

/// Background task status provider
final backgroundTaskStatusProvider = Provider<Map<String, dynamic>>((ref) {
  return BackgroundTaskHandler.getStatus();
});

/// Background task controller provider
final backgroundTaskControllerProvider = Provider<BackgroundTaskController>((ref) {
  return BackgroundTaskController(ref as WidgetRef);
});

/// Controller class for background tasks
class BackgroundTaskController {
  final WidgetRef ref;

  BackgroundTaskController(this.ref);

  /// Start background tasks
  void start() {
    BackgroundTaskHandler.initialize(ref);
  }

  /// Stop background tasks
  void stop() {
    BackgroundTaskHandler.stop();
  }

  /// Pause background tasks
  void pause() {
    BackgroundTaskHandler.pause();
  }

  /// Resume background tasks
  void resume() {
    BackgroundTaskHandler.resume(ref);
  }

  /// Force refresh
  Future<void> forceRefresh() async {
    await BackgroundTaskHandler.forceRefresh(ref);
  }

  /// Reset background tasks
  void reset() {
    BackgroundTaskHandler.reset(ref);
  }

  /// Get current status
  Map<String, dynamic> getStatus() {
    return BackgroundTaskHandler.getStatus();
  }
}