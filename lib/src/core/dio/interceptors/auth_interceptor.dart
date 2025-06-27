import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/auth_state_provider.dart';
import '../../../domain/usecases/refresh_token_usecase.dart';
import '../../utils/jwt_decoder_util.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login and refresh endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    final authState = _ref.read(authStateProvider);

    if (authState.isAuthenticated) {
      if (authState.accessToken != null) {
        // Check if token is expired or about to expire
        if (JwtDecoderUtil.isTokenExpired(authState.accessToken!)) {
          try {
            // Force refresh token
            await _ref.read(authStateProvider.notifier).forceRefreshToken();
            
            // Get the new token
            final newAuthState = _ref.read(authStateProvider);
            if (newAuthState.accessToken != null) {
              options.headers['Authorization'] = 'Bearer ${newAuthState.accessToken}';
            } else {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'No valid access token available',
                ),
              );
            }
          } catch (e) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Token refresh failed: $e',
              ),
            );
          }
        } else {
          options.headers['Authorization'] = 'Bearer ${authState.accessToken}';
        }
      } else {
        // User is authenticated but no access token
        // Try to refresh
        try {
          await _ref.read(authStateProvider.notifier).forceRefreshToken();
          final newAuthState = _ref.read(authStateProvider);
          if (newAuthState.accessToken != null) {
            options.headers['Authorization'] = 'Bearer ${newAuthState.accessToken}';
          } else {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Unable to obtain access token',
              ),
            );
          }
        } catch (e) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Token refresh failed: $e',
            ),
          );
        }
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !_isAuthEndpoint(err.requestOptions.path)) {
      try {
        // Force refresh token
        await _ref.read(authStateProvider.notifier).forceRefreshToken();
        
        // Get the new token
        final authState = _ref.read(authStateProvider);
        if (authState.accessToken != null) {
          // Retry original request with new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer ${authState.accessToken}';

          final dio = Dio();
          final response = await dio.fetch(options);
          return handler.resolve(response);
        } else {
          // No access token available, let the error through
          return handler.next(err);
        }
      } catch (e) {
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') || 
           path.contains('/auth/refresh') ||
           path.contains('/auth/logout');
  }
}