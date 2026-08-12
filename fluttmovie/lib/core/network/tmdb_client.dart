import 'package:dio/dio.dart';

import '../config/api_config.dart';

class TmdbClient {
  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        queryParameters: {'api_key': ApiConfig.apiKey},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }
}
