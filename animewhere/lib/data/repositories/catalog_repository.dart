import 'package:animewhere/core/models/title.dart';
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

  final JikanApi jikanApi;
  final AniListApi anilistApi;
  final KitsuApi kitsuApi;
  final Duration ttl;

  final Map<String, _CachedResult> _cache = {};

  Future<Result<List<Title>>> carousel() {
    return _fetch('carousel', jikanApi.topAnime);
  }

  Future<Result<List<Title>>> latest() {
    return _fetch('latest', jikanApi.seasonsNow);
  }

  Future<Result<List<Title>>> trending() {
    return _fetch('trending', anilistApi.trendingAnime);
  }

  Future<Result<List<Title>>> popular() {
    return _fetch('popular', anilistApi.popularAnime);
  }

  Future<Result<List<Title>>> manga() {
    return _fetch('manga', kitsuApi.manga);
  }

  Future<Result<List<Title>>> _fetch(
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
          ? const Empty<List<Title>>()
          : Data<List<Title>>(titles);
      _cache[key] = _CachedResult(result);
      return result;
    } on AppException catch (error) {
      return Failure<List<Title>>(error);
    }
  }
}

class _CachedResult {
  _CachedResult(this.result) : fetchedAt = DateTime.now();

  final Result<List<Title>> result;
  final DateTime fetchedAt;

  bool isFresh(Duration ttl) {
    return DateTime.now().difference(fetchedAt) <= ttl;
  }
}
