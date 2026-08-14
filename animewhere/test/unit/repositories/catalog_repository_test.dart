import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/repositories/catalog_repository.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';

Title title(int id) => Title(
  id: '$id',
  source: TitleSource.jikan,
  kind: TitleKind.anime,
  title: 'Title $id',
  imageUrl: 'https://example.com/$id.jpg',
);

class _FakeJikanApi extends JikanApi {
  _FakeJikanApi({this.top, this.seasons, this.seasonsError});

  final List<Title>? top;
  final List<Title>? seasons;
  AppException? seasonsError;
  int topCalls = 0;
  int seasonsCalls = 0;

  @override
  Future<List<Title>> topAnime({int limit = 10}) async {
    topCalls++;
    return top ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsNow({int limit = 20}) async {
    seasonsCalls++;
    if (seasonsError != null) throw seasonsError!;
    return seasons ?? <Title>[];
  }
}

class _FakeAniListApi extends AniListApi {
  _FakeAniListApi({this.trending, this.popular});

  final List<Title>? trending;
  final List<Title>? popular;
  int trendingCalls = 0;
  int popularCalls = 0;

  @override
  Future<List<Title>> trendingAnime() async {
    trendingCalls++;
    return trending ?? <Title>[];
  }

  @override
  Future<List<Title>> popularAnime() async {
    popularCalls++;
    return popular ?? <Title>[];
  }
}

class _FakeKitsuApi extends KitsuApi {
  _FakeKitsuApi({this.mangaData, this.error});

  final List<Title>? mangaData;
  AppException? error;
  int mangaCalls = 0;

  @override
  Future<List<Title>> manga({int limit = 10}) async {
    mangaCalls++;
    if (error != null) throw error!;
    return mangaData ?? <Title>[];
  }
}

void main() {
  group('CatalogRepository', () {
    test('assembles each source into a typed result', () async {
      final jikan = _FakeJikanApi(
        top: [title(1), title(2)],
        seasons: [title(3)],
      );
      final anilist = _FakeAniListApi(
        trending: [title(4)],
        popular: [title(5)],
      );
      final kitsu = _FakeKitsuApi(mangaData: [title(6), title(7)]);
      final repo = CatalogRepository(
        jikanApi: jikan,
        anilistApi: anilist,
        kitsuApi: kitsu,
      );

      final carousel = await repo.carousel();
      final latest = await repo.latest();
      final trending = await repo.trending();
      final popular = await repo.popular();
      final manga = await repo.manga();

      expect(carousel, isA<Data<List<Title>>>());
      expect((carousel as Data<List<Title>>).value, hasLength(2));
      expect((latest as Data<List<Title>>).value, hasLength(1));
      expect((trending as Data<List<Title>>).value, hasLength(1));
      expect((popular as Data<List<Title>>).value, hasLength(1));
      expect((manga as Data<List<Title>>).value, hasLength(2));
    });

    test('caches successful results within the TTL', () async {
      final kitsu = _FakeKitsuApi(mangaData: [title(1)]);
      final repo = CatalogRepository(
        jikanApi: _FakeJikanApi(),
        anilistApi: _FakeAniListApi(),
        kitsuApi: kitsu,
      );

      final first = await repo.manga();
      final second = await repo.manga();

      expect(kitsu.mangaCalls, 1);
      expect(first, isA<Data<List<Title>>>());
      expect(second, isA<Data<List<Title>>>());
    });

    test('refetches after the TTL expires', () async {
      final kitsu = _FakeKitsuApi(mangaData: [title(1)]);
      final repo = CatalogRepository(
        jikanApi: _FakeJikanApi(),
        anilistApi: _FakeAniListApi(),
        kitsuApi: kitsu,
        ttl: const Duration(milliseconds: 20),
      );

      await repo.manga();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      await repo.manga();

      expect(kitsu.mangaCalls, 2);
    });

    test('does not cache failures; a retry hits the source again', () async {
      final kitsu = _FakeKitsuApi(
        mangaData: [title(1)],
        error: const RateLimitError(),
      );
      final repo = CatalogRepository(
        jikanApi: _FakeJikanApi(),
        anilistApi: _FakeAniListApi(),
        kitsuApi: kitsu,
      );

      final first = await repo.manga();
      expect(first, isA<Failure<List<Title>>>());
      expect((first as Failure<List<Title>>).error, isA<RateLimitError>());

      kitsu.error = null;
      final second = await repo.manga();
      expect(kitsu.mangaCalls, 2);
      expect(second, isA<Data<List<Title>>>());
    });

    test('maps typed source failures without masking other sources', () async {
      final jikan = _FakeJikanApi(
        top: [title(1)],
        seasons: [title(2)],
        seasonsError: const RateLimitError(),
      );
      final anilist = _FakeAniListApi(trending: [title(3)]);
      final kitsu = _FakeKitsuApi(mangaData: [title(4)]);
      final repo = CatalogRepository(
        jikanApi: jikan,
        anilistApi: anilist,
        kitsuApi: kitsu,
      );

      final latest = await repo.latest();
      final carousel = await repo.carousel();
      final trending = await repo.trending();
      final manga = await repo.manga();

      expect(latest, isA<Failure<List<Title>>>());
      expect((latest as Failure<List<Title>>).error, isA<RateLimitError>());
      expect(carousel, isA<Data<List<Title>>>());
      expect(trending, isA<Data<List<Title>>>());
      expect(manga, isA<Data<List<Title>>>());
    });

    test(
      'a successful but empty payload surfaces as Empty, not Data',
      () async {
        final repo = CatalogRepository(
          jikanApi: _FakeJikanApi(),
          anilistApi: _FakeAniListApi(),
          kitsuApi: _FakeKitsuApi(),
        );

        final manga = await repo.manga();
        expect(manga, isA<Empty<List<Title>>>());
      },
    );
  });
}
