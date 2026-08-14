import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_page.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';

class CatalogRepository {
  CatalogRepository({
    required this.jikanApi,
    required this.anilistApi,
    required this.kitsuApi,
    this.ttl = const Duration(minutes: 5),
  });

  static const int _pageSize = 10;

  final JikanApi jikanApi;
  final AniListApi anilistApi;
  final KitsuApi kitsuApi;
  final Duration ttl;

  final Map<String, _CachedResult> _cache = {};

  Future<Result<TitlePage>> jikanCarousel() {
    return _fetchPage('jikan:carousel', () => jikanApi.topAnime(page: 1));
  }

  Future<Result<TitlePage>> jikanSeasonal(int page) {
    return _fetchPage(
      'jikan:seasonal:$page',
      () => jikanApi.seasonsNow(page: page),
    );
  }

  Future<Result<TitlePage>> jikanUpcoming(int page) {
    return _fetchPage(
      'jikan:upcoming:$page',
      () => jikanApi.seasonsUpcoming(page: page),
    );
  }

  Future<Result<TitlePage>> anilistCarousel() {
    return _fetchPage(
      'anilist:carousel',
      () => anilistApi.trendingAnime(page: 1),
    );
  }

  Future<Result<TitlePage>> anilistPopular(int page) {
    return _fetchPage(
      'anilist:popular:$page',
      () => anilistApi.popularAnime(page: page),
    );
  }

  Future<Result<TitlePage>> anilistTopRated(int page) {
    return _fetchPage(
      'anilist:top-rated:$page',
      () => anilistApi.topRatedAnime(page: page),
    );
  }

  Future<Result<TitlePage>> kitsuCarousel() {
    return _fetchPage('kitsu:carousel', () => kitsuApi.manga());
  }

  Future<Result<TitlePage>> kitsuManga(int page) {
    return _fetchPage('kitsu:manga:$page', () => kitsuApi.manga(page: page));
  }

  Future<Result<TitlePage>> kitsuAnime(int page) {
    return _fetchPage('kitsu:anime:$page', () => kitsuApi.anime(page: page));
  }

  Future<Result<TitlePage>> _fetchPage(
    String key,
    Future<List<Title>> Function() request,
  ) async {
    final cached = _cache[key];
    if (cached != null && cached.isFresh(ttl)) {
      return cached.result;
    }

    try {
      final titles = await request();
      final result = titles.isEmpty
          ? const Empty<TitlePage>()
          : Data<TitlePage>(
              TitlePage(titles: titles, hasMore: titles.length == _pageSize),
            );
      _cache[key] = _CachedResult(result);
      return result;
    } on AppException catch (error) {
      return Failure<TitlePage>(error);
    }
  }
}

class _CachedResult {
  _CachedResult(this.result) : fetchedAt = DateTime.now();

  final Result<TitlePage> result;
  final DateTime fetchedAt;

  bool isFresh(Duration ttl) {
    return DateTime.now().difference(fetchedAt) <= ttl;
  }
}
