import '../entities/movie.dart';
import '../repositories/share_repository.dart';

class ShareMovie {
  ShareMovie(this._shareRepository);

  final ShareRepository _shareRepository;

  static const String _tmdbBaseUrl = 'https://www.themoviedb.org/movie/';

  Future<void> call(Movie movie) async {
    final message = 'Olha esse filme que encontrei no FLUTTMOV: '
        '${movie.title} - $_tmdbBaseUrl${movie.id}';
    await _shareRepository.shareText(message);
  }
}
