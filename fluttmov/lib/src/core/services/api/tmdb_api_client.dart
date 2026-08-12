import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import 'api_interceptors.dart';

class TmdbApiClient {
  TmdbApiClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                responseType: ResponseType.json,
              ),
            )..interceptors.add(AuthInterceptor());

  final Dio dio;
}
