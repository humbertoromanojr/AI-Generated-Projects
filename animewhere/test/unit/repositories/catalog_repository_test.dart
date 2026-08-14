import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_page.dart';
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

List<Title> page10(int start) => [
  for (var i = start; i < start + 10; i++) title(i),
];

class _FakeJikanApi extends JikanApi {
  _FakeJikanApi({this.top, this.seasonal, this.upcoming, this.seasonalError});

  final List<Title>? top;
  List<Title>? seasonal;
  List<Title>? upcoming;
  AppException? seasonalError;
  AppException? upcomingError;
  int topCalls = 0;
  int seasonalCalls = 0;
  int upcomingCalls = 0;
  int? lastSeasonalPage;
  int? lastUpcomingPage;

  @override
  Future<List<Title>> topAnime({int page = 1, int limit = 10}) async {
    topCalls++;
    return top ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsNow({int page = 1, int limit = 10}) async {
    seasonalCalls++;
    lastSeasonalPage = page;
    if (seasonalError != null) throw seasonalError!;
    return seasonal ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsUpcoming({int page = 1, int limit = 10}) async {
    upcomingCalls++;
    lastUpcomingPage = page;
    if (upcomingError != null) throw upcomingError!;
    return upcoming ?? <Title>[];
  }
}

class _FakeAniListApi extends AniListApi {
  _FakeAniListApi({this.trending, this.popular, this.topRated});

  final List<Title>? trending;
  final List<Title>? popular;
  final List<Title>? topRated;
  int trendingCalls = 0;
  int popularCalls = 0;
  int topRatedCalls = 0;
  int? lastPopularPage;
  int? lastTopRatedPage;

  @override
  Future<List<Title>> trendingAnime({int page = 1}) async {
    trendingCalls++;
    return trending ?? <Title>[];
  }

  @override
  Future<List<Title>> popularAnime({int page = 1}) async {
    popularCalls++;
    lastPopularPage = page;
    return popular ?? <Title>[];
  }

  @override
  Future<List<Title>> topRatedAnime({int page = 1}) async {
    topRatedCalls++;
    lastTopRatedPage = page;
    return topRated ?? <Title>[];
  }
}

class _FakeKitsuApi extends KitsuApi {
  _FakeKitsuApi({this.mangaData, this.animeData, this.error});

  final List<Title>? mangaData;
  final List<Title>? animeData;
  AppException? error;
  int mangaCalls = 0;
  int animeCalls = 0;
  int? lastMangaPage;
  int? lastAnimePage;

  @override
  Future<List<Title>> manga({int page = 0, int limit = 10}) async {
    mangaCalls++;
    lastMangaPage = page;
    if (error != null) throw error!;
    return mangaData ?? <Title>[];
  }

  @override
  Future<List<Title>> anime({int page = 0, int limit = 10}) async {
    animeCalls++;
    lastAnimePage = page;
    if (error != null) throw error!;
    return animeData ?? <Title>[];
  }
}

void main() {
  group('CatalogRepository page-based accessors', () {
    test('jikan accessors return typed TitlePage results', () async {
      final jikan = _FakeJikanApi(
        top: [title(1), title(2)],
        seasonal: [title(3)],
        upcoming: [title(4)],
      );
      final repo = CatalogRepository(
        jikanApi: jikan,
        anilistApi: _FakeAniListApi(),
        kitsuApi: _FakeKitsuApi(),
      );

      final carousel = await repo.jikanCarousel();
      final seasonal = await repo.jikanSeasonal(1);
      final upcoming = await repo.jikanUpcoming(1);

      expect(carousel, isA<Data<TitlePage>>());
      expect((carousel as Data<TitlePage>).value.titles, hasLength(2));
      expect((seasonal as Data<TitlePage>).value.titles, hasLength(1));
      expect((upcoming as Data<TitlePage>).value.titles, hasLength(1));
      expect(jikan.lastSeasonalPage, 1);
      expect(jikan.lastUpcomingPage, 1);
    });

    test('anilist accessors return typed TitlePage results', () async {
      final anilist = _FakeAniListApi(
        trending: [title(1)],
        popular: [title(2)],
        topRated: [title(3)],
      );
      final repo = CatalogRepository(
        jikanApi: _FakeJikanApi(),
        anilistApi: anilist,
        kitsuApi: _FakeKitsuApi(),
      );

      final carousel = await repo.anilistCarousel();
      final popular = await repo.anilistPopular(2);
      final topRated = await repo.anilistTopRated(3);

      expect(carousel, isA<Data<TitlePage>>());
      expect((carousel as Data<TitlePage>).value.titles, hasLength(1));
      expect((popular as Data<TitlePage>).value.titles, hasLength(1));
      expect((topRated as Data<TitlePage>).value.titles, hasLength(1));
      expect(anilist.lastPopularPage, 2);
      expect(anilist.lastTopRatedPage, 3);
    });

    test('kitsu accessors return typed TitlePage results', () async {
      final kitsu = _FakeKitsuApi(mangaData: [title(1)], animeData: [title(2)]);
      final repo = CatalogRepository(
        jikanApi: _FakeJikanApi(),
        anilistApi: _FakeAniListApi(),
        kitsuApi: kitsu,
      );

      final carousel = await repo.kitsuCarousel();
      final manga = await repo.kitsuManga(1);
      final anime = await repo.kitsuAnime(2);

      expect(carousel, isA<Data<TitlePage>>());
      expect((carousel as Data<TitlePage>).value.titles, hasLength(1));
      expect((manga as Data<TitlePage>).value.titles, hasLength(1));
      expect((anime as Data<TitlePage>).value.titles, hasLength(1));
      expect(kitsu.lastMangaPage, 1);
      expect(kitsu.lastAnimePage, 2);
    });

    test('hasMore flips false when a page has fewer than 10 titles', () async {
      final jikan = _FakeJikanApi(seasonal: [title(1)]);
      final repo = CatalogRepository(
        jikanApi: jikan,
        anilistApi: _FakeAniListApi(),
        kitsuApi: _FakeKitsuApi(),
      );

      final short = await repo.jikanSeasonal(1);
      expect((short as Data<TitlePage>).value.hasMore, isFalse);

      final full = await repo.jikanSeasonal(2);
      expect((full as Data<TitlePage>).value.hasMore, isFalse);
    });

    test('hasMore flips true when a page has exactly 10 titles', () async {
      final jikan = _FakeJikanApi(seasonal: page10(0));
      final repo = CatalogRepository(
        jikanApi: jikan,
        anilistApi: _FakeAniListApi(),
        kitsuApi: _FakeKitsuApi(),
      );

      final page = await repo.jikanSeasonal(1);
      expect((page as Data<TitlePage>).value.titles, hasLength(10));
      expect(page.value.hasMore, isTrue);
    });

    test('caches each page independently', () async {
      final jikan = _FakeJikanApi(seasonal: page10(0));
      final repo = CatalogRepository(
        jikanApi: jikan,
        anilistApi: _FakeAniListApi(),
        kitsuApi: _FakeKitsuApi(),
      );

      final first = await repo.jikanSeasonal(1);
      final firstAgain = await repo.jikanSeasonal(1);
      expect(firstAgain, same(first));
      expect(jikan.seasonalCalls, 1);

      final second = await repo.jikanSeasonal(2);
      expect(second, isNot(same(first)));
      expect(jikan.seasonalCalls, 2);
    });

    test('carousels use their own cache keys', () async {
      final jikan = _FakeJikanApi(top: [title(1)]);
      final repo = CatalogRepository(
        jikanApi: jikan,
        anilistApi: _FakeAniListApi(),
        kitsuApi: _FakeKitsuApi(),
      );

      await repo.jikanCarousel();
      await repo.jikanCarousel();
      expect(jikan.topCalls, 1);
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

      final first = await repo.kitsuManga(1);
      expect(first, isA<Failure<TitlePage>>());
      expect((first as Failure<TitlePage>).error, isA<RateLimitError>());

      kitsu.error = null;
      final second = await repo.kitsuManga(1);
      expect(kitsu.mangaCalls, 2);
      expect(second, isA<Data<TitlePage>>());
    });

    test(
      'maps typed source failures without masking other accessors',
      () async {
        final jikan = _FakeJikanApi(
          seasonal: [title(2)],
          seasonalError: const RateLimitError(),
        );
        final anilist = _FakeAniListApi(trending: [title(3)]);
        final repo = CatalogRepository(
          jikanApi: jikan,
          anilistApi: anilist,
          kitsuApi: _FakeKitsuApi(),
        );

        final seasonal = await repo.jikanSeasonal(1);
        final carousel = await repo.anilistCarousel();

        expect(seasonal, isA<Failure<TitlePage>>());
        expect((seasonal as Failure<TitlePage>).error, isA<RateLimitError>());
        expect(carousel, isA<Data<TitlePage>>());
      },
    );

    test(
      'a successful but empty payload surfaces as Empty, not Data',
      () async {
        final repo = CatalogRepository(
          jikanApi: _FakeJikanApi(),
          anilistApi: _FakeAniListApi(),
          kitsuApi: _FakeKitsuApi(),
        );

        final seasonal = await repo.jikanSeasonal(1);
        expect(seasonal, isA<Empty<TitlePage>>());
      },
    );
  });

  group('Carousel accessors (US2 - fixed page 1, 10-item cap)', () {
    test('jikanCarousel requests exactly 10 on page 1 and caches', () async {
      final jikan = _FakeJikanApi(top: page10(0));
      final repo = CatalogRepository(
        jikanApi: jikan,
        anilistApi: _FakeAniListApi(),
        kitsuApi: _FakeKitsuApi(),
      );

      final first = await repo.jikanCarousel();
      expect(jikan.topCalls, 1);

      final typed = first as Data<TitlePage>;
      expect(typed.value.titles, hasLength(10));
      expect(typed.value.hasMore, isTrue);

      // Second call must be served from cache — no new request
      final cached = await repo.jikanCarousel();
      expect(jikan.topCalls, 1);
      expect(cached, same(first));
    });

    test('anilistCarousel requests exactly 10 on page 1 and caches', () async {
      final anilist = _FakeAniListApi(trending: page10(0));
      final repo = CatalogRepository(
        jikanApi: _FakeJikanApi(),
        anilistApi: anilist,
        kitsuApi: _FakeKitsuApi(),
      );

      final first = await repo.anilistCarousel();
      expect(anilist.trendingCalls, 1);

      final typed = first as Data<TitlePage>;
      expect(typed.value.titles, hasLength(10));
      expect(typed.value.hasMore, isTrue);

      final cached = await repo.anilistCarousel();
      expect(anilist.trendingCalls, 1);
      expect(cached, same(first));
    });

    test('kitsuCarousel requests exactly 10 on page 1 and caches', () async {
      final kitsu = _FakeKitsuApi(mangaData: page10(0));
      final repo = CatalogRepository(
        jikanApi: _FakeJikanApi(),
        anilistApi: _FakeAniListApi(),
        kitsuApi: kitsu,
      );

      final first = await repo.kitsuCarousel();
      expect(kitsu.mangaCalls, 1);

      final typed = first as Data<TitlePage>;
      expect(typed.value.titles, hasLength(10));
      expect(typed.value.hasMore, isTrue);

      final cached = await repo.kitsuCarousel();
      expect(kitsu.mangaCalls, 1);
      expect(cached, same(first));
    });

    test('carousel accessors have no page parameter (fixed page 1)', () {
      // Verify that the carousel accessors don't accept a page argument
      // by checking they can be called with no arguments
      final repo = CatalogRepository(
        jikanApi: _FakeJikanApi(top: page10(0)),
        anilistApi: _FakeAniListApi(trending: page10(0)),
        kitsuApi: _FakeKitsuApi(mangaData: page10(0)),
      );

      // These calls should compile — no page param required
      expect(repo.jikanCarousel(), isA<Future<Result<TitlePage>>>());
      expect(repo.anilistCarousel(), isA<Future<Result<TitlePage>>>());
      expect(repo.kitsuCarousel(), isA<Future<Result<TitlePage>>>());
    });
  });
}
