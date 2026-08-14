// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart' hide Title;
import 'package:flutter_test/flutter_test.dart';

import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_source.dart';
import 'package:animewhere/core/network/network_error.dart';
import 'package:animewhere/data/repositories/catalog_repository.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';
import 'package:animewhere/ui/home/home_view.dart';
import 'package:animewhere/ui/home/home_view_model.dart';
import 'package:animewhere/ui/home/widgets/catalog_section.dart';
import 'package:animewhere/ui/home/widgets/infinite_title_row.dart';

Title title(int id) => Title(
  id: '$id',
  source: TitleSource.jikan,
  kind: TitleKind.anime,
  title: 'Title $id',
  imageUrl: 'https://example.com/$id.jpg',
);

class _FakeJikanApi extends JikanApi {
  _FakeJikanApi({this.top, this.seasons, this.topError});

  final List<Title>? top;
  final List<Title>? seasons;
  final AppException? topError;
  int topCalls = 0;

  @override
  Future<List<Title>> topAnime({int page = 1, int limit = 10}) async {
    topCalls++;
    if (topError != null) throw topError!;
    return top ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsNow({int page = 1, int limit = 10}) async {
    return seasons ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsUpcoming({int page = 1, int limit = 10}) async {
    return seasons ?? <Title>[];
  }
}

class _FakeAniListApi extends AniListApi {
  _FakeAniListApi({this.trending, this.popular});

  final List<Title>? trending;
  final List<Title>? popular;
  int trendingCalls = 0;

  @override
  Future<List<Title>> trendingAnime({int page = 1}) async {
    trendingCalls++;
    return trending ?? <Title>[];
  }

  @override
  Future<List<Title>> popularAnime({int page = 1}) async {
    return popular ?? <Title>[];
  }

  @override
  Future<List<Title>> topRatedAnime({int page = 1}) async {
    return <Title>[];
  }
}

class _FakeKitsuApi extends KitsuApi {
  _FakeKitsuApi({this.mangaData});

  final List<Title>? mangaData;
  int mangaCalls = 0;
  int mangaCarouselCalls = 0;

  @override
  Future<List<Title>> manga({int page = 0, int limit = 10}) async {
    mangaCalls++;
    if (page == 0) mangaCarouselCalls++;
    return mangaData ?? <Title>[];
  }

  @override
  Future<List<Title>> anime({int page = 0, int limit = 10}) async {
    return <Title>[];
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
  testWidgets(
    'renders three section headers in order (jikan, anilist, kitsu)',
    (WidgetTester tester) async {
      final vm = HomeViewModel(repository: _repo());

      await tester.pumpWidget(MaterialApp(home: HomeView(viewModel: vm)));
      await vm.load();
      await tester.pump();

      expect(find.byType(CatalogSection), findsNWidgets(3));
      expect(find.text('Jikan'), findsOneWidget);
      expect(find.text('AniList'), findsOneWidget);
      expect(find.text('Kitsu'), findsOneWidget);
    },
  );

  testWidgets('renders an error state with a retry action', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final vm = HomeViewModel(
      repository: _repo(
        jikan: _FakeJikanApi(topError: const HttpError(statusCode: 500)),
        anilist: _FakeAniListApi(trending: [title(4)]),
      ),
    );
    await vm.load();

    await tester.pumpWidget(MaterialApp(home: HomeView(viewModel: vm)));
    await tester.pump();

    expect(find.text('Jikan'), findsOneWidget);
    expect(find.text('AniList'), findsOneWidget);
    expect(find.text('Retry'), findsWidgets);
    expect(find.text('Title 4'), findsOneWidget);
  });

  testWidgets('renders empty state when a section has no titles', (
    WidgetTester tester,
  ) async {
    final vm = HomeViewModel(repository: _repo());
    await vm.load();

    await tester.pumpWidget(MaterialApp(home: HomeView(viewModel: vm)));
    await tester.pump();

    expect(find.text('Jikan'), findsOneWidget);
    expect(find.textContaining('No titles'), findsWidgets);
  });

  testWidgets(
    'carousels render exactly 10 items and issue no further requests while idle',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final jikan = _FakeJikanApi(top: List.generate(10, (i) => title(i + 1)));
      final anilist = _FakeAniListApi(
        trending: List.generate(10, (i) => title(i + 11)),
      );
      final kitsu = _FakeKitsuApi(
        mangaData: List.generate(10, (i) => title(i + 21)),
      );

      final vm = HomeViewModel(
        repository: CatalogRepository(
          jikanApi: jikan,
          anilistApi: anilist,
          kitsuApi: kitsu,
        ),
      );
      await vm.load();

      await tester.pumpWidget(MaterialApp(home: HomeView(viewModel: vm)));
      await tester.pump();

      // Each carousel should show a counter "1 / 10"
      expect(find.text('1 / 10'), findsNWidgets(3));

      // Record call counts after initial load
      final jikanCalls = jikan.topCalls;
      final anilistCalls = anilist.trendingCalls;
      final kitsuCarouselCalls = kitsu.mangaCarouselCalls;

      // Pump again — no additional carousel requests should occur
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(jikan.topCalls, jikanCalls);
      expect(anilist.trendingCalls, anilistCalls);
      expect(kitsu.mangaCarouselCalls, kitsuCarouselCalls);

      // Verify each carousel was called exactly once (not 0, not 3+)
      expect(jikanCalls, 1);
      expect(anilistCalls, 1);
      expect(kitsuCarouselCalls, 1);
    },
  );

  group('InfiniteTitleRow', () {
    Widget row({
      required List<Title> titles,
      required bool hasMore,
      required bool isLoadingMore,
      required bool loadFailed,
      VoidCallback? onLoadMore,
      VoidCallback? onRetry,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InfiniteTitleRow(
              titles: titles,
              label: 'Seasonal',
              hasMore: hasMore,
              isLoadingMore: isLoadingMore,
              loadFailed: loadFailed,
              onLoadMore: onLoadMore ?? () {},
              onTitleTap: (_) {},
              onTitleShare: (_) {},
              onRetry: onRetry ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('scrolling near the end triggers onLoadMore', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      var loadMoreCalls = 0;
      await tester.pumpWidget(
        row(
          titles: List.generate(10, (i) => title(i + 1)),
          hasMore: true,
          isLoadingMore: false,
          loadFailed: false,
          onLoadMore: () => loadMoreCalls++,
        ),
      );

      await tester.drag(find.byType(InfiniteTitleRow), const Offset(-1000, 0));
      await tester.pump();

      expect(loadMoreCalls, greaterThan(0));
    });

    testWidgets('shows a trailing mini-spinner while loading more', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        row(
          titles: List.generate(3, (i) => title(i + 1)),
          hasMore: true,
          isLoadingMore: true,
          loadFailed: false,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Title 1'), findsOneWidget);
    });

    testWidgets('shows a quiet end marker when the catalog is exhausted', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        row(
          titles: List.generate(3, (i) => title(i + 1)),
          hasMore: false,
          isLoadingMore: false,
          loadFailed: false,
        ),
      );

      expect(find.text('End of catalog'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('keeps titles visible and shows retry on load failure', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      var retries = 0;
      await tester.pumpWidget(
        row(
          titles: List.generate(3, (i) => title(i + 1)),
          hasMore: true,
          isLoadingMore: false,
          loadFailed: true,
          onLoadMore: () => retries++,
        ),
      );

      expect(find.text('Title 1'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retries, 1);
    });
  });
}
