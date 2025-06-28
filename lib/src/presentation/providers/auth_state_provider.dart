import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/jwt_decoder_util.dart';
import '../../core/utils/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';

class AuthState {
  final bool isAuthenticated;
  final String? accessToken; // In memory only
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.isAuthenticated = false,
    this.accessToken,
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? accessToken,
    User? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;

  Timer? _refreshTimer;
  Timer? _periodicRefreshTimer;

  AuthStateNotifier(
    this._loginUseCase,
    this._logoutUseCase,
    this._refreshTokenUseCase,
  ) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check if user was previously logged in
      final isLoggedIn = await SecureStorage.isLoggedIn();
      final hasValidRefreshToken = await SecureStorage.hasValidRefreshToken();

      if (isLoggedIn && hasValidRefreshToken) {
        // Try to refresh token to get new access token
        final result = await _refreshTokenUseCase();

        await result.fold(
          (failure) async {
            // Refresh failed, but keep user logged in state
            // They might be offline or server might be down
            final userData = await SecureStorage.getUserData();
            if (userData != null) {
              state = state.copyWith(
                isAuthenticated: true,
                user: userData,
                isLoading: false,
                isInitialized: true,
                accessToken: null, // No valid access token
              );
              // Try again later
              _schedulePeriodicRefresh();
            } else {
              // No user data, logout
              await _performLogout();
            }
          },
          (accessToken) async {
            final userData = await SecureStorage.getUserData();
            state = state.copyWith(
              isAuthenticated: true,
              accessToken: accessToken,
              user: userData,
              isLoading: false,
              isInitialized: true,
            );
            _scheduleTokenRefresh(accessToken);
            _schedulePeriodicRefresh();
          },
        );
      } else {
        // Not logged in or refresh token expired
        await SecureStorage.deleteAll();
        state = state.copyWith(isLoading: false, isInitialized: true);
      }
    } catch (e) {
      print('Auth initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: 'Failed to initialize authentication',
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUseCase(email, password);

    await result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (data) async {
        print(data);
        final (token, refreshToken, user) = data;

        // Save persistent data
        await Future.wait([
          SecureStorage.saveRefreshToken(refreshToken),
          SecureStorage.saveUserData(user),
          SecureStorage.setLoggedIn(true),
        ]);

        state = state.copyWith(
          isAuthenticated: true,
          accessToken: token,
          user: user,
          isLoading: false,
          error: null,
        );

        _scheduleTokenRefresh(token);
        _schedulePeriodicRefresh();
      },
    );
  }

  Future<void> logout() async {
    await _performLogout();
  }

  Future<void> _performLogout() async {
    // Cancel all timers
    _refreshTimer?.cancel();
    _periodicRefreshTimer?.cancel();

    // Call logout API
    await _logoutUseCase();

    // Clear all persistent data
    await SecureStorage.deleteAll();

    state = const AuthState(isInitialized: true);
  }

  void _scheduleTokenRefresh(String token) {
    _refreshTimer?.cancel();

    try {
      final expiryTime = JwtDecoderUtil.getExpiryTime(token);
      final now = DateTime.now();
      final difference = expiryTime.difference(now);

      // Refresh 1 minute before expiry or immediately if already expired
      final refreshDuration = difference - AppConstants.tokenRefreshBuffer;

      if (refreshDuration.isNegative) {
        // Token already expired or about to expire
        _refreshAccessToken();
      } else {
        _refreshTimer = Timer(refreshDuration, _refreshAccessToken);
      }
    } catch (e) {
      print('Error scheduling token refresh: $e');
      // Fallback to periodic refresh
      _schedulePeriodicRefresh();
    }
  }

  void _schedulePeriodicRefresh() {
    _periodicRefreshTimer?.cancel();

    // Refresh every 9 minutes regardless of token expiry
    _periodicRefreshTimer = Timer.periodic(
      AppConstants.refreshInterval,
      (_) => _refreshAccessToken(),
    );
  }

  Future<void> _refreshAccessToken() async {
    if (!state.isAuthenticated) return;

    final result = await _refreshTokenUseCase();

    await result.fold(
      (failure) async {
        print('Token refresh failed: ${failure.message}');

        // Check if we still have a valid refresh token
        final hasValidRefreshToken = await SecureStorage.hasValidRefreshToken();

        if (!hasValidRefreshToken) {
          // Refresh token expired, logout user
          await _performLogout();
        } else {
          // Keep user logged in but without access token
          // They might be offline
          state = state.copyWith(accessToken: null);

          // Try again in 1 minute
          Timer(const Duration(minutes: 1), _refreshAccessToken);
        }
      },
      (accessToken) async {
        state = state.copyWith(accessToken: accessToken);
        _scheduleTokenRefresh(accessToken);
      },
    );
  }

  // Force refresh token (for manual refresh)
  Future<void> forceRefreshToken() async {
    await _refreshAccessToken();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _periodicRefreshTimer?.cancel();
    super.dispose();
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  return AuthStateNotifier(
    ref.read(loginUseCaseProvider),
    ref.read(logoutUseCaseProvider),
    ref.read(refreshTokenUseCaseProvider),
  );
});

// Helper provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

// Helper provider to get current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

// Helper provider to get access token
final accessTokenProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).accessToken;
});
