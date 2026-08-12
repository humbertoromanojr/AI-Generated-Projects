import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  const AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters['api_key'] = AppConfig.tmdbApiKey;
    options.queryParameters['language'] = ApiConfig.language;
    handler.next(options);
  }
}

bool isConnectionError(DioException error) {
  return switch (error.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout =>
      true,
    _ => false,
  };
}
