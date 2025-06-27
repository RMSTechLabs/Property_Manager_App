import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final options = err.requestOptions;
      final retryCount = options.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        options.extra['retryCount'] = retryCount + 1;
        
        // Wait before retrying
        await Future.delayed(retryDelay * (retryCount + 1));
        
        try {
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue with error if retry fails
        }
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode == 503) || // Service Unavailable
        (error.response?.statusCode == 502); // Bad Gateway
  }
}