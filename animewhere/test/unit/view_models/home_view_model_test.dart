import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/models/title_page.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/data/repositories/catalog_repository.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';
import 'package:animewhere/ui/home/home_view_model.dart';

Title title(int id) => Title(
  id: '$id',
  source: TitleSource.jikan,
  kind: TitleKind.anime,
  title: 'Title $id',
  imageUrl: 'https://example.com/$id.jpg',
);

class _FakeJikanApi extends JikanApi {
  _FakeJikanApi({
    this.top,
    this.seasons,
    this.topError,
    this.seasonsError,
    this.topGate,
    this.seasonsLoader,
  });

  final List<Title>? top;
  final List<Title>? seasons;
  AppException? topError;
  final AppException? seasonsError;
  final Completer<List<Title>>? topGate;
  final Future<List<Title>> Function(int page)? seasonsLoader;

  @override
  Future<List<Title>> topAnime({int page = 1, int limit = 10}) async {
    if (topGate != null) return topGate!.future;
    if (topError != null) throw topError!;
    return top ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsNow({int page = 1, int limit = 10}) async {
    if (seasonsError != null) throw seasonsError!;
    final loader = seasonsLoader;
    if (loader != null) return loader(page);
    return seasons ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsUpcoming({int page = 1, int limit = 10}) async {
    if (seasonsError != null) throw seasonsError!;
    final loader = seasonsLoader;
    if (loader != null) return loader(page);
    return seasons ?? <Title>[];
  }
}

class _FakeAniListApi extends AniListApi {
  _FakeAniListApi({this.trending, this.popular, this.topRated});

  final List<Title>? trending;
  final List<Title>? popular;
  final List<Title>? topRated;

  @override
  Future<List<Title>> trendingAnime({int page = 1}) async {
    return trending ?? <Title>[];
  }

  @override
  Future<List<Title>> popularAnime({int page = 1}) async {
    return popular ?? <Title>[];
  }

  @override
  Future<List<Title>> topRatedAnime({int page = 1}) async {
    return topRated ?? <Title>[];
  }
}

class _FakeKitsuApi extends KitsuApi {
  _FakeKitsuApi({this.mangaData, this.animeData});

  final List<Title>? mangaData;
  final List<Title>? animeData;

  @override
  Future<List<Title>> manga({int page = 0, int limit = 10}) async {
    return mangaData ?? <Title>[];
  }

  @override
  Future<List<Title>> anime({int page = 0, int limit = 10}) async {
    return animeData ?? <Title>[];
  }
}

CatalogRepository _repo({
  _FakeJikanApi? jikan,
  _FakeAniListApi? anilist,
  _FakeKitsuApi? kitsu,
}) {
  return CatalogRepository(
    jikanApi: jikan ?? _FakeJikanApi(),
    anilistApi: anilist ?? _FakeAniListApi(),
    kitsuApi: kitsu ?? _FakeKitsuApi(),
  );
}

void main() {
  group('HomeViewModel', () {
    test('initializes with three sections (jikan, anilist, kitsu)', () {
      final vm = HomeViewModel(repository: _repo());

      expect(vm.sections.length, 3);
      expect(vm.sections[0].id, 'jikan');
      expect(vm.sections[1].id, 'anilist');
      expect(vm.sections[2].id, 'kitsu');

      expect(vm.sections[0].label, 'Jikan');
      expect(vm.sections[1].label, 'AniList');
      expect(vm.sections[2].label, 'Kitsu');

      expect(vm.sections[0].carousel, isA<Loading<TitlePage>>());
      expect(vm.sections[1].carousel, isA<Loading<TitlePage>>());
      expect(vm.sections[2].carousel, isA<Loading<TitlePage>>());

      expect(vm.sections[0].rows.length, 2);
      expect(vm.sections[1].rows.length, 2);
      expect(vm.sections[2].rows.length, 2);

      expect(vm.sections[0].rows[0].id, 'seasonal');
      expect(vm.sections[0].rows[1].id, 'upcoming');
      expect(vm.sections[1].rows[0].id, 'popular');
      expect(vm.sections[1].rows[1].id, 'topRated');
      expect(vm.sections[2].rows[0].id, 'manga');
      expect(vm.sections[2].rows[1].id, 'anime');
    });

    test('loads data into all three sections', () async {
      final vm = HomeViewModel(
        repository: _repo(
          jikan: _FakeJikanApi(
            top: [title(1), title(2), title(3)],
            seasons: [title(4)],
            topError: null,
          ),
          anilist: _FakeAniListApi(
            trending: [title(5)],
            popular: [title(6)],
            topRated: [title(7)],
          ),
          kitsu: _FakeKitsuApi(mangaData: [title(8)], animeData: [title(9)]),
        ),
      );

      await vm.load();

      expect(vm.sections[0].carousel, isA<Data<TitlePage>>());
      expect(
        (vm.sections[0].carousel as Data<TitlePage>).value.titles,
        hasLength(3),
      );

      expect(vm.sections[1].carousel, isA<Data<TitlePage>>());
      expect(
        (vm.sections[1].carousel as Data<TitlePage>).value.titles,
        hasLength(1),
      );

      expect(vm.sections[2].carousel, isA<Data<TitlePage>>());
      expect(
        (vm.sections[2].carousel as Data<TitlePage>).value.titles,
        hasLength(1),
      );

      expect(vm.sections[0].rows[0].titles, hasLength(1));
      expect(vm.sections[0].rows[1].titles, hasLength(1));

      expect(vm.isInitialLoading, isFalse);
    });

    test('a Jikan failure must not blank the other two sections', () async {
      final jikan = _FakeJikanApi(
        top: [title(1)],
        seasons: [title(2)],
        topError: const HttpError(statusCode: 500),
        seasonsError: const RateLimitError(),
      );
      final anilist = _FakeAniListApi(
        trending: [title(3)],
        popular: [title(4)],
        topRated: [title(10)],
      );
      final kitsu = _FakeKitsuApi(mangaData: [title(5)], animeData: [title(6)]);

      final vm = HomeViewModel(
        repository: _repo(jikan: jikan, anilist: anilist, kitsu: kitsu),
      );

      await vm.load();

      expect(vm.sections[0].carousel, isA<Failure<TitlePage>>());
      expect(
        (vm.sections[0].carousel as Failure<TitlePage>).error,
        isA<HttpError>(),
      );

      expect(vm.sections[1].carousel, isA<Data<TitlePage>>());
      expect(vm.sections[2].carousel, isA<Data<TitlePage>>());

      expect(vm.sections[1].rows[0].titles, hasLength(1));
      expect(vm.sections[1].rows[1].titles, hasLength(1));
      expect(vm.sections[2].rows[0].titles, hasLength(1));
      expect(vm.sections[2].rows[1].titles, hasLength(1));
    });

    test(
      'refresh keeps previously loaded content when a source fails',
      () async {
        final jikan = _FakeJikanApi(top: [title(1)], seasons: [title(2)]);
        final vm = HomeViewModel(repository: _repo(jikan: jikan));

        await vm.load();
        expect(vm.sections[0].carousel, isA<Data<TitlePage>>());

        jikan.topError = const RateLimitError();
        await vm.refresh();

        expect(vm.sections[0].carousel, isA<Data<TitlePage>>());
        expect(
          (vm.sections[0].carousel as Data<TitlePage>).value.titles,
          hasLength(1),
        );
      },
    );

    test('exposes loading to data transitions through notifier', () async {
      final gate = Completer<List<Title>>();
      final jikan = _FakeJikanApi(top: [title(1), title(2)], topGate: gate);
      final vm = HomeViewModel(repository: _repo(jikan: jikan));

      var notified = 0;
      vm.addListener(() => notified++);

      final future = vm.load();
      await Future<void>.delayed(Duration.zero);
      expect(vm.isInitialLoading, isTrue);
      expect(vm.sections[0].carousel, isA<Loading<TitlePage>>());

      gate.complete([title(1), title(2)]);
      await future;

      expect(vm.isInitialLoading, isFalse);
      expect(vm.sections[0].carousel, isA<Data<TitlePage>>());
      expect(notified, greaterThan(0));
    });
  });

  group('HomeViewModel.loadMore', () {
    List<Title> titles(int start, int count) =>
        List.generate(count, (i) => title(start + i));

    test('appends the next page exactly once', () async {
      final jikan = _FakeJikanApi(
        top: [title(1)],
        seasonsLoader: (page) async =>
            page == 1 ? titles(100, 10) : titles(200, 10),
      );
      final vm = HomeViewModel(repository: _repo(jikan: jikan));

      await vm.load();
      final row = vm.sections[0].rows[0];
      expect(row.titles, hasLength(10));
      expect(row.nextPage, 2);
      expect(row.hasMore, isTrue);

      await vm.loadMore('jikan', 'seasonal');

      final updated = vm.sections[0].rows[0];
      expect(updated.titles, hasLength(20));
      expect(updated.titles.first.id, '100');
      expect(updated.titles.last.id, '209');
      expect(updated.nextPage, 3);
      expect(updated.hasMore, isTrue);
      expect(updated.isLoadingMore, isFalse);
      expect(updated.loadFailed, isFalse);
    });

    test('single-flight guard blocks overlapping loads', () async {
      final gate = Completer<List<Title>>();
      var page2Requests = 0;
      final jikan = _FakeJikanApi(
        top: [title(1)],
        seasonsLoader: (page) {
          if (page == 1) return Future.value(titles(100, 10));
          page2Requests++;
          return gate.future;
        },
      );
      final vm = HomeViewModel(repository: _repo(jikan: jikan));
      await vm.load();

      final first = vm.loadMore('jikan', 'seasonal');
      final second = vm.loadMore('jikan', 'seasonal');
      expect(page2Requests, 1);

      gate.complete(titles(200, 10));
      await Future.wait([first, second]);

      final row = vm.sections[0].rows[0];
      expect(row.titles, hasLength(20));
      expect(row.isLoadingMore, isFalse);
      expect(page2Requests, 1);
    });

    test('hasMore flips false on a short page', () async {
      final jikan = _FakeJikanApi(
        top: [title(1)],
        seasonsLoader: (page) async =>
            page == 1 ? titles(100, 10) : titles(200, 3),
      );
      final vm = HomeViewModel(repository: _repo(jikan: jikan));
      await vm.load();

      await vm.loadMore('jikan', 'seasonal');

      final row = vm.sections[0].rows[0];
      expect(row.titles, hasLength(13));
      expect(row.hasMore, isFalse);
      expect(row.isLoadingMore, isFalse);
    });

    test('duplicates by source+id are skipped', () async {
      final jikan = _FakeJikanApi(
        top: [title(1)],
        seasonsLoader: (page) async => page == 1
            ? titles(100, 10)
            : [...titles(104, 4), ...titles(210, 6)],
      );
      final vm = HomeViewModel(repository: _repo(jikan: jikan));
      await vm.load();

      await vm.loadMore('jikan', 'seasonal');

      final row = vm.sections[0].rows[0];
      expect(row.titles, hasLength(16));
      final ids = row.titles.map((t) => t.id).toSet();
      expect(ids.length, row.titles.length);
    });

    test('failure keeps loaded titles and sets retry state', () async {
      var failPage2 = true;
      final jikan = _FakeJikanApi(
        top: [title(1)],
        seasonsLoader: (page) async {
          if (page == 1) return titles(100, 10);
          if (failPage2) {
            failPage2 = false;
            throw const RateLimitError();
          }
          return titles(200, 10);
        },
      );
      final vm = HomeViewModel(repository: _repo(jikan: jikan));
      await vm.load();

      await vm.loadMore('jikan', 'seasonal');

      final row = vm.sections[0].rows[0];
      expect(row.titles, hasLength(10));
      expect(row.loadFailed, isTrue);
      expect(row.isLoadingMore, isFalse);
      expect(row.hasMore, isTrue);
      expect(row.nextPage, 2);

      await vm.loadMore('jikan', 'seasonal');
      final updated = vm.sections[0].rows[0];
      expect(updated.loadFailed, isFalse);
      expect(updated.titles, hasLength(20));
    });
  });
}
