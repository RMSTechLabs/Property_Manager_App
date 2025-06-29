// import 'dart:async';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:property_manager_app/src/data/models/send_otp_response_model.dart';
// import 'package:property_manager_app/src/domain/usecases/send_otp_usecase.dart';
// import 'package:property_manager_app/src/domain/usecases/validate_otp_usecase.dart';

// import '../../core/constants/app_constants.dart';
// import '../../core/utils/jwt_decoder_util.dart';
// import '../../core/utils/secure_storage.dart';
// import '../../domain/entities/user.dart';
// import '../../domain/usecases/login_usecase.dart';
// import '../../domain/usecases/logout_usecase.dart';
// import '../../domain/usecases/refresh_token_usecase.dart';

// class AuthState {
//   final bool isAuthenticated;
//   final String? accessToken; // In memory only
//   final User? user;
//   final bool isLoading;
//   final String? error;
//   final bool isInitialized;
//   final bool isOtpVerified;
//   final String? message;
//   final String? otpIdentifier;

//   const AuthState({
//     this.isAuthenticated = false,
//     this.accessToken,
//     this.user,
//     this.isLoading = false,
//     this.error,
//     this.isInitialized = false,
//     this.isOtpVerified = false,
//     this.message,
//     this.otpIdentifier,
//   });

//   AuthState copyWith({
//     bool? isAuthenticated,
//     String? accessToken,
//     User? user,
//     bool? isLoading,
//     String? error,
//     bool? isInitialized,
//     bool? isOtpVerified,
//     String? message,
//     String? otpIdentifier,
//   }) {
//     return AuthState(
//       isAuthenticated: isAuthenticated ?? this.isAuthenticated,
//       accessToken: accessToken ?? this.accessToken,
//       user: user ?? this.user,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//       isInitialized: isInitialized ?? this.isInitialized,
//       isOtpVerified: isOtpVerified ?? this.isOtpVerified,
//       message: message ?? this.message,
//       otpIdentifier: otpIdentifier ?? this.otpIdentifier,
//     );
//   }
// }

// class AuthStateNotifier extends StateNotifier<AuthState> {
//   final LoginUseCase _loginUseCase;
//   final LogoutUseCase _logoutUseCase;
//   final RefreshTokenUseCase _refreshTokenUseCase;
//   final SendOtpUseCase _sendOtpUseCase;
//   final ValidateOtpUseCase _validateOtpUseCase;

//   Timer? _refreshTimer;
//   Timer? _periodicRefreshTimer;

//   AuthStateNotifier(
//     this._loginUseCase,
//     this._logoutUseCase,
//     this._refreshTokenUseCase,
//     this._sendOtpUseCase,
//     this._validateOtpUseCase,
//   ) : super(const AuthState()) {
//     _initializeAuth();
//   }

//   Future<void> _initializeAuth() async {
//     state = state.copyWith(isLoading: true);
//     try {
//       // Check if user was previously logged in
//       final isLoggedIn = await SecureStorage.isLoggedIn();
//       final hasValidRefreshToken = await SecureStorage.hasValidRefreshToken();

//       if (isLoggedIn && hasValidRefreshToken) {
//         // Try to refresh token to get new access token
//         final result = await _refreshTokenUseCase();
//         await result.fold(
//           (failure) async {
//             // Refresh failed, but keep user logged in state
//             // They might be offline or server might be down
//             final userData = await SecureStorage.getUserData();
//             if (userData != null) {
//               state = state.copyWith(
//                 isAuthenticated: true,
//                 user: userData,
//                 isLoading: false,
//                 isInitialized: true,
//                 accessToken: null, // No valid access token
//                 isOtpVerified: false,
//               );
//               // Try again later
//               _schedulePeriodicRefresh();
//             } else {
//               // No user data, logout
//               await _performLogout();
//             }
//           },
//           (accessToken) async {
//             final userData = await SecureStorage.getUserData();
//             state = state.copyWith(
//               isAuthenticated: true,
//               accessToken: accessToken,
//               user: userData,
//               isLoading: false,
//               isInitialized: true,
//               isOtpVerified: true, //
//             );
//             _scheduleTokenRefresh(accessToken);
//             _schedulePeriodicRefresh();
//           },
//         );
//       } else {
//         // Not logged in or refresh token expired
//         await SecureStorage.deleteAll();
//         state = state.copyWith(isLoading: false, isInitialized: true);
//       }
//     } catch (e) {
//       print('Auth initialization error: $e');
//       state = state.copyWith(
//         isLoading: false,
//         isInitialized: true,
//         error: 'Failed to initialize authentication',
//       );
//     }
//   }

//   Future<void> login(String email, String password) async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await _loginUseCase(email, password);
//     await result.fold(
//       (failure) async {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           isAuthenticated: false,
//         );
//       },
//       (data) async {
//         final (token, refreshToken, user) = data;
//         // Save persistent data
//         await Future.wait([
//           SecureStorage.saveRefreshToken(refreshToken),
//           SecureStorage.saveUserData(user),
//           SecureStorage.setLoggedIn(true),
//         ]);

//         state = state.copyWith(
//           isAuthenticated: true,
//           accessToken: token,
//           user: user,
//           isLoading: false,
//           error: null,
//         );

//         _scheduleTokenRefresh(token);
//         _schedulePeriodicRefresh();
//       },
//     );
//   }

//   Future<void> sendOtp(String email) async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await _sendOtpUseCase(email);
//     await result.fold(
//       (failure) async {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           isAuthenticated: false,
//           isOtpVerified: false, //
//         );
//       },
//       (data) async {
//         final SendOtpResponseModel model = data;
//         state = state.copyWith(
//           isAuthenticated: true,
//           isLoading: false,
//           isOtpVerified: model.validate,
//           otpIdentifier: model.otpIdentifier,
//           message: model.message,
//           error: null,
//         );
//       },
//     );
//   }

//   Future<void> validateOtp(String otp, String otpIdentifier) async {
//     state = state.copyWith(isLoading: true, error: null);
//     final result = await _validateOtpUseCase(otp, otpIdentifier);
//     await result.fold(
//       (failure) async {
//         state = state.copyWith(
//           isLoading: false,
//           error: failure.message,
//           isAuthenticated: false,
//           isOtpVerified: false, //
//         );
//       },
//       (data) async {
//         state = state.copyWith(
//           isAuthenticated: true,
//           isLoading: false,
//           isOtpVerified: data,
//           otpIdentifier: otpIdentifier,
//           error: null,
//         );
//       },
//     );
//   }

//   // Add these methods to your auth provider

//   Future<void> logout() async {
//     await _performLogout();
//   }

//   Future<void> _performLogout() async {
//     // Cancel all timers
//     _refreshTimer?.cancel();
//     _periodicRefreshTimer?.cancel();

//     // Call logout API
//     await _logoutUseCase();

//     // Clear all persistent data
//     await SecureStorage.deleteAll();

//     state = const AuthState(isInitialized: true);
//   }

//   void _scheduleTokenRefresh(String token) {
//     _refreshTimer?.cancel();

//     try {
//       final expiryTime = JwtDecoderUtil.getExpiryTime(token);
//       final now = DateTime.now();
//       final difference = expiryTime.difference(now);

//       // Refresh 1 minute before expiry or immediately if already expired
//       final refreshDuration = difference - AppConstants.tokenRefreshBuffer;

//       if (refreshDuration.isNegative) {
//         // Token already expired or about to expire
//         _refreshAccessToken();
//       } else {
//         _refreshTimer = Timer(refreshDuration, _refreshAccessToken);
//       }
//     } catch (e) {
//       print('Error scheduling token refresh: $e');
//       // Fallback to periodic refresh
//       _schedulePeriodicRefresh();
//     }
//   }

//   void _schedulePeriodicRefresh() {
//     _periodicRefreshTimer?.cancel();

//     // Refresh every 9 minutes regardless of token expiry
//     _periodicRefreshTimer = Timer.periodic(
//       AppConstants.refreshInterval,
//       (_) => _refreshAccessToken(),
//     );
//   }

//   Future<void> _refreshAccessToken() async {
//     if (!state.isAuthenticated) return;
//     final result = await _refreshTokenUseCase();
//     await result.fold(
//       (failure) async {
//         print('Token refresh failed: ${failure.message}');

//         // Check if we still have a valid refresh token
//         final hasValidRefreshToken = await SecureStorage.hasValidRefreshToken();

//         if (!hasValidRefreshToken) {
//           // Refresh token expired, logout user
//           await _performLogout();
//         } else {
//           // Keep user logged in but without access token
//           // They might be offline
//           state = state.copyWith(accessToken: null);

//           // Try again in 1 minute
//           Timer(const Duration(minutes: 1), _refreshAccessToken);
//         }
//       },
//       (accessToken) async {
//         state = state.copyWith(accessToken: accessToken);
//         _scheduleTokenRefresh(accessToken);
//       },
//     );
//   }

//   // Force refresh token (for manual refresh)
//   Future<void> forceRefreshToken() async {
//     await _refreshAccessToken();
//   }

//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     _periodicRefreshTimer?.cancel();
//     super.dispose();
//   }
// }

// final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
//   ref,
// ) {
//   return AuthStateNotifier(
//     ref.read(loginUseCaseProvider),
//     ref.read(logoutUseCaseProvider),
//     ref.read(refreshTokenUseCaseProvider),
//     ref.read(sendOtpUseCaseProvider),
//     ref.read(validateOtpUseCaseProvider),
//   );
// });

// // Helper provider to check if user is authenticated
// final isAuthenticatedProvider = Provider<bool>((ref) {
//   return ref.watch(authStateProvider).isAuthenticated;
// });

// // Helper provider to get current user
// final currentUserProvider = Provider<User?>((ref) {
//   return ref.watch(authStateProvider).user;
// });

// // Helper provider to get access token
// final accessTokenProvider = Provider<String?>((ref) {
//   return ref.watch(authStateProvider).accessToken;
// });

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/data/models/send_otp_response_model.dart';
import 'package:property_manager_app/src/domain/usecases/send_otp_usecase.dart';
import 'package:property_manager_app/src/domain/usecases/validate_otp_usecase.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/jwt_decoder_util.dart';
import '../../core/utils/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';

enum AuthStep {
  initial,
  authenticating,
  authenticated,
  sendingOtp,
  otpSent,
  verifyingOtp,
  verified,
  error,
}

class AuthState {
  final AuthStep step;
  final String? accessToken;
  final String? refreshToken;
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;
  final String? otpIdentifier;
  final String? email;

  const AuthState({
    this.step = AuthStep.initial,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
    this.otpIdentifier,
    this.email,
  });

  bool get isAuthenticated =>
      step == AuthStep.authenticated ||
      step == AuthStep.sendingOtp ||
      step == AuthStep.otpSent ||
      step == AuthStep.verifyingOtp ||
      step == AuthStep.verified;

  bool get isOtpVerified => step == AuthStep.verified;

  bool get needsOtpVerification =>
      step == AuthStep.authenticated ||
      step == AuthStep.sendingOtp ||
      step == AuthStep.otpSent;

  AuthState copyWith({
    AuthStep? step,
    String? accessToken,
    String? refreshToken,
    User? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    String? otpIdentifier,
    String? email,
  }) {
    return AuthState(
      step: step ?? this.step,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
      otpIdentifier: otpIdentifier ?? this.otpIdentifier,
      email: email ?? this.email,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final ValidateOtpUseCase _validateOtpUseCase;

  Timer? _refreshTimer;
  Timer? _periodicRefreshTimer;

  AuthStateNotifier(
    this._loginUseCase,
    this._logoutUseCase,
    this._refreshTokenUseCase,
    this._sendOtpUseCase,
    this._validateOtpUseCase,
  ) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final isLoggedIn = await SecureStorage.isLoggedIn();
      final hasValidRefreshToken = await SecureStorage.hasValidRefreshToken();

      if (isLoggedIn && hasValidRefreshToken) {
        final result = await _refreshTokenUseCase();
        await result.fold(
          (failure) async {
            final userData = await SecureStorage.getUserData();
            if (userData != null) {
              state = state.copyWith(
                step: AuthStep.verified, // Assume verified if was logged in
                user: userData,
                isLoading: false,
                isInitialized: true,
              );
              _schedulePeriodicRefresh();
            } else {
              await _performLogout();
            }
          },
          (accessToken) async {
            final userData = await SecureStorage.getUserData();
            state = state.copyWith(
              step: AuthStep.verified,
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
        await SecureStorage.deleteAll();
        state = state.copyWith(
          step: AuthStep.initial,
          isLoading: false,
          isInitialized: true,
        );
      }
    } catch (e) {
      print('Auth initialization error: $e');
      state = state.copyWith(
        step: AuthStep.error,
        isLoading: false,
        isInitialized: true,
        error: 'Failed to initialize authentication',
      );
    }
  }

  // Force refresh token (for manual refresh)
  Future<void> forceRefreshToken() async {
    await _refreshAccessToken();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(
      step: AuthStep.authenticating,
      isLoading: true,
      error: null,
      email: email,
    );

    final result = await _loginUseCase(email, password);
    await result.fold(
      (failure) async {
        state = state.copyWith(
          step: AuthStep.error,
          isLoading: false,
          error: failure.message,
        );
      },
      (data) async {
        final (token, refreshToken, user) = data;

        // Store refresh token and user data
        await Future.wait([
          SecureStorage.saveRefreshToken(refreshToken),
          SecureStorage.saveUserData(user),
        ]);

        // Update state to authenticated (but not verified)
        state = state.copyWith(
          step: AuthStep.authenticated,
          accessToken: token,
          refreshToken: refreshToken,
          user: user,
          isLoading: false,
          error: null,
        );

        // Automatically send OTP after successful login
        await sendOtp();
      },
    );
  }

  Future<void> sendOtp([String? email]) async {
    final emailToUse = email ?? state.email ?? state.user?.email;
    if (emailToUse == null) {
      state = state.copyWith(
        step: AuthStep.error,
        error: 'Email not found',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      step: AuthStep.sendingOtp,
      isLoading: true,
      error: null,
    );

    final result = await _sendOtpUseCase(emailToUse);
    print('🙄$result');
    await result.fold(
      (failure) async {
        state = state.copyWith(
          step: AuthStep.error,
          isLoading: false,
          error: failure.message,
        );
      },
      (data) async {
        print(data.toJson());
        final SendOtpResponseModel model = data;
        state = state.copyWith(
          step: AuthStep.otpSent,
          isLoading: false,
          otpIdentifier: model.otpIdentifier,
          error: null,
        );
      },
    );
  }

  Future<void> validateOtp(String otp) async {
    if (state.otpIdentifier == null) {
      state = state.copyWith(
        step: AuthStep.error,
        error: 'OTP identifier not found',
      );
      return;
    }

    state = state.copyWith(
      step: AuthStep.verifyingOtp,
      isLoading: true,
      error: null,
    );

    final result = await _validateOtpUseCase(otp, state.otpIdentifier!);
    await result.fold(
      (failure) async {
        state = state.copyWith(
          step: AuthStep.otpSent, // Go back to OTP sent state
          isLoading: false,
          error: failure.message,
        );
      },
      (isValid) async {
        if (isValid) {
          // Mark as logged in
          await SecureStorage.setLoggedIn(true);

          state = state.copyWith(
            step: AuthStep.verified,
            isLoading: false,
            error: null,
          );

          // Schedule token refresh
          if (state.accessToken != null) {
            _scheduleTokenRefresh(state.accessToken!);
            _schedulePeriodicRefresh();
          }
        } else {
          state = state.copyWith(
            step: AuthStep.otpSent,
            isLoading: false,
            error: 'Invalid OTP',
          );
        }
      },
    );
  }

  Future<void> resendOtp() async {
    await sendOtp();
  }

  Future<void> logout() async {
    await _performLogout();
  }

  Future<void> _performLogout() async {
    _refreshTimer?.cancel();
    _periodicRefreshTimer?.cancel();

    await _logoutUseCase();
    await SecureStorage.deleteAll();

    state = const AuthState(step: AuthStep.initial, isInitialized: true);
  }

  void _scheduleTokenRefresh(String token) {
    _refreshTimer?.cancel();

    try {
      final expiryTime = JwtDecoderUtil.getExpiryTime(token);
      final now = DateTime.now();
      final difference = expiryTime.difference(now);
      final refreshDuration = difference - AppConstants.tokenRefreshBuffer;

      if (refreshDuration.isNegative) {
        _refreshAccessToken();
      } else {
        _refreshTimer = Timer(refreshDuration, _refreshAccessToken);
      }
    } catch (e) {
      print('Error scheduling token refresh: $e');
      _schedulePeriodicRefresh();
    }
  }

  void _schedulePeriodicRefresh() {
    _periodicRefreshTimer?.cancel();
    _periodicRefreshTimer = Timer.periodic(
      AppConstants.refreshInterval,
      (_) => _refreshAccessToken(),
    );
  }

  Future<void> _refreshAccessToken() async {
    if (state.step != AuthStep.verified) return;

    final result = await _refreshTokenUseCase();
    await result.fold(
      (failure) async {
        print('Token refresh failed: ${failure.message}');
        final hasValidRefreshToken = await SecureStorage.hasValidRefreshToken();

        if (!hasValidRefreshToken) {
          await _performLogout();
        } else {
          state = state.copyWith(accessToken: null);
          Timer(const Duration(minutes: 1), _refreshAccessToken);
        }
      },
      (accessToken) async {
        state = state.copyWith(accessToken: accessToken);
        _scheduleTokenRefresh(accessToken);
      },
    );
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
    ref.read(sendOtpUseCaseProvider),
    ref.read(validateOtpUseCaseProvider),
  );
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

final isOtpVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isOtpVerified;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

final accessTokenProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).accessToken;
});
