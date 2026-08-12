import '../config/api_config.dart';

class TmdbImageUrls {
  static String? poster(String? path, {String size = 'w500'}) =>
      path == null ? null : '${ApiConfig.imageBaseUrl}$size$path';

  static String? backdrop(String? path, {String size = 'w780'}) =>
      path == null ? null : '${ApiConfig.imageBaseUrl}$size$path';

  static String? profile(String? path) =>
      path == null ? null : '${ApiConfig.imageBaseUrl}w185$path';
}
