// lib/src/presentation/providers/fcm_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../data/datasources/fcm_remote_datasource.dart';

class FCMState {
  final String? currentToken;
  final bool isRegistered;
  final String? error;

  const FCMState({
    this.currentToken,
    this.isRegistered = false,
    this.error,
  });

  FCMState copyWith({
    String? currentToken,
    bool? isRegistered,
    String? error,
  }) {
    return FCMState(
      currentToken: currentToken ?? this.currentToken,
      isRegistered: isRegistered ?? this.isRegistered,
      error: error,
    );
  }
}

class FCMNotifier extends StateNotifier<FCMState> {
  final FCMRemoteDataSource _fcmDataSource;
  final Logger _logger = Logger(printer: PrettyPrinter());
  StreamSubscription<String>? _tokenRefreshSubscription;

  FCMNotifier(this._fcmDataSource) : super(const FCMState()) {
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    try {
      _logger.i('🔔 Initializing FCM...');
      
      // Get initial token
      final token = await _fcmDataSource.getFCMToken();
      state = state.copyWith(currentToken: token);
      
      // Listen for token refresh
      _tokenRefreshSubscription = _fcmDataSource.tokenRefreshStream.listen(
        (newToken) {
          _logger.i('🔄 FCM token refreshed');
          state = state.copyWith(currentToken: newToken);
          // You can call API to update token here if user is logged in
        },
        onError: (error) {
          _logger.e('❌ FCM token refresh error: $error');
          state = state.copyWith(error: 'Token refresh failed: $error');
        },
      );
      
    } catch (e) {
      _logger.e('❌ FCM initialization failed: $e');
      state = state.copyWith(error: 'FCM initialization failed: $e');
    }
  }

  Future<void> registerDevice(String userId, String accessToken) async {
    try {
      await _fcmDataSource.registerDevice(userId, accessToken);
      state = state.copyWith(isRegistered: true, error: null);
    } catch (e) {
      _logger.e('❌ Device registration failed: $e');
      state = state.copyWith(error: 'Device registration failed: $e');
    }
  }

  Future<void> updateToken(String userId, String accessToken) async {
    try {
      if (state.currentToken != null) {
        await _fcmDataSource.updateDeviceToken(userId, state.currentToken!, accessToken);
      }
    } catch (e) {
      _logger.e('❌ Token update failed: $e');
      state = state.copyWith(error: 'Token update failed: $e');
    }
  }

  Future<void> unregisterDevice(String userId, String accessToken) async {
    try {
      await _fcmDataSource.unregisterDevice(userId, accessToken);
      state = state.copyWith(isRegistered: false, error: null);
    } catch (e) {
      _logger.e('❌ Device unregistration failed: $e');
      // Don't update state with error for unregistration
    }
  }

  @override
  void dispose() {
    _tokenRefreshSubscription?.cancel();
    super.dispose();
  }
}

final fcmProvider = StateNotifierProvider<FCMNotifier, FCMState>((ref) {
  final fcmDataSource = ref.watch(fcmRemoteDataSourceProvider);
  return FCMNotifier(fcmDataSource);
});