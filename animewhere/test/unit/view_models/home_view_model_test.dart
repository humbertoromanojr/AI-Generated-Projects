import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
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
  });

  final List<Title>? top;
  final List<Title>? seasons;
  AppException? topError;
  final AppException? seasonsError;
  final Completer<List<Title>>? topGate;

  @override
  Future<List<Title>> topAnime({int limit = 10}) async {
    if (topGate != null) return topGate!.future;
    if (topError != null) throw topError!;
    return top ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsNow({int limit = 20}) async {
    if (seasonsError != null) throw seasonsError!;
    return seasons ?? <Title>[];
  }
}

class _FakeAniListApi extends AniListApi {
  _FakeAniListApi({this.trending, this.popular});

  final List<Title>? trending;
  final List<Title>? popular;

  @override
  Future<List<Title>> trendingAnime() async {
    return trending ?? <Title>[];
  }

  @override
  Future<List<Title>> popularAnime() async {
    return popular ?? <Title>[];
  }
}

class _FakeKitsuApi extends KitsuApi {
  _FakeKitsuApi({this.mangaData});

  final List<Title>? mangaData;

  @override
  Future<List<Title>> manga({int limit = 10}) async {
    return mangaData ?? <Title>[];
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
    test('starts every section in the loading state', () {
      final vm = HomeViewModel(
        repository: _repo(jikan: _FakeJikanApi(top: [title(1)])),
      );

      expect(vm.carousel, isA<Loading<List<Title>>>());
      for (final row in vm.rows) {
        expect(row.result, isA<Loading<List<Title>>>());
      }
      expect(vm.isInitialLoading, isTrue);
    });

    test('loads data into the carousel and every row', () async {
      final vm = HomeViewModel(
        repository: _repo(
          jikan: _FakeJikanApi(top: [title(1), title(2)], seasons: [title(3)]),
          anilist: _FakeAniListApi(trending: [title(4)], popular: [title(5)]),
          kitsu: _FakeKitsuApi(mangaData: [title(6)]),
        ),
      );

      await vm.load();

      expect(vm.carousel, isA<Data<List<Title>>>());
      expect((vm.carousel as Data<List<Title>>).value, hasLength(2));

      final rowsById = {for (final r in vm.rows) r.id: r};
      expect(
        (rowsById['latest']!.result as Data<List<Title>>).value,
        hasLength(1),
      );
      expect(
        (rowsById['trending']!.result as Data<List<Title>>).value,
        hasLength(1),
      );
      expect(
        (rowsById['popular']!.result as Data<List<Title>>).value,
        hasLength(1),
      );
      expect(
        (rowsById['manga']!.result as Data<List<Title>>).value,
        hasLength(1),
      );
      expect(vm.isInitialLoading, isFalse);
    });

    test('a Jikan failure must not blank AniList and Kitsu rows', () async {
      final jikan = _FakeJikanApi(
        top: [title(1)],
        seasons: [title(2)],
        topError: const HttpError(statusCode: 500),
        seasonsError: const RateLimitError(),
      );
      final vm = HomeViewModel(
        repository: _repo(
          jikan: jikan,
          anilist: _FakeAniListApi(trending: [title(4)], popular: [title(5)]),
          kitsu: _FakeKitsuApi(mangaData: [title(6)]),
        ),
      );

      await vm.load();

      expect(vm.carousel, isA<Failure<List<Title>>>());
      expect((vm.carousel as Failure<List<Title>>).error, isA<HttpError>());

      final rowsById = {for (final r in vm.rows) r.id: r};
      expect(rowsById['latest']!.result, isA<Failure<List<Title>>>());

      expect(rowsById['trending']!.result, isA<Data<List<Title>>>());
      expect(rowsById['popular']!.result, isA<Data<List<Title>>>());
      expect(rowsById['manga']!.result, isA<Data<List<Title>>>());
    });

    test(
      'refresh keeps previously loaded content when a source fails',
      () async {
        final jikan = _FakeJikanApi(top: [title(1)], seasons: [title(2)]);
        final vm = HomeViewModel(repository: _repo(jikan: jikan));

        await vm.load();
        expect(vm.carousel, isA<Data<List<Title>>>());

        jikan.topError = const RateLimitError();
        await vm.refresh();

        expect(vm.carousel, isA<Data<List<Title>>>());
        expect((vm.carousel as Data<List<Title>>).value, hasLength(1));
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
      expect(vm.carousel, isA<Loading<List<Title>>>());

      gate.complete([title(1), title(2)]);
      await future;

      expect(vm.isInitialLoading, isFalse);
      expect(vm.carousel, isA<Data<List<Title>>>());
      expect(notified, greaterThan(0));
    });
  });
}
