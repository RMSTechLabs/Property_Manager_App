import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // _logger.i(
    //   'REQUEST[${options.method}] => PATH: ${options.path} '
    //   'DATA: ${options.data} HEADERS: ${options.headers}',
    // );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // _logger.i(
    //   'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path} '
    //   'DATA: ${response.data}',
    // );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // _logger.e(
    //   'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path} '
    //   'MESSAGE: ${err.message}',
    // );
    super.onError(err, handler);
  }
}