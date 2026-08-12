import '../config/api_config.dart';
import '../constants/tmdb_image_sizes.dart';

class ImageUrlBuilder {
  const ImageUrlBuilder._();

  static String? poster(String? path, {String size = TmdbImageSizes.posterLarge}) {
    if (path == null || path.isEmpty) return null;
    return '${ApiConfig.imageBaseUrl}/$size$path';
  }

  static String? backdrop(String? path, {String size = TmdbImageSizes.backdropMedium}) {
    if (path == null || path.isEmpty) return null;
    return '${ApiConfig.imageBaseUrl}/$size$path';
  }

  static String? profile(String? path) {
    if (path == null || path.isEmpty) return null;
    return '${ApiConfig.imageBaseUrl}/${TmdbImageSizes.profileSmall}$path';
  }
}
