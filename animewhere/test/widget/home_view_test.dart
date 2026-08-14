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

  @override
  Future<List<Title>> topAnime({int limit = 10}) async {
    if (topError != null) throw topError!;
    return top ?? <Title>[];
  }

  @override
  Future<List<Title>> seasonsNow({int limit = 20}) async {
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

Widget _wrap(HomeViewModel vm) {
  return MaterialApp(home: HomeView(viewModel: vm));
}

void main() {
  testWidgets('renders loading states while sections are pending', (
    WidgetTester tester,
  ) async {
    final vm = HomeViewModel(repository: _repo());

    await tester.pumpWidget(_wrap(vm));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(vm.isInitialLoading, isTrue);
  });

  testWidgets('renders populated carousel and rows with labels', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final vm = HomeViewModel(
      repository: _repo(
        jikan: _FakeJikanApi(top: [title(1), title(2)], seasons: [title(3)]),
        anilist: _FakeAniListApi(trending: [title(4)], popular: [title(5)]),
        kitsu: _FakeKitsuApi(mangaData: [title(6)]),
      ),
    );
    await vm.load();

    await tester.pumpWidget(_wrap(vm));
    await tester.pump();

    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('Manga'), findsOneWidget);
    expect(find.text('Title 1'), findsOneWidget);
    expect(find.text('Title 6'), findsOneWidget);
  });

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

    await tester.pumpWidget(_wrap(vm));
    await tester.pump();

    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('Retry'), findsWidgets);
    expect(find.text('Title 4'), findsOneWidget);
  });

  testWidgets('renders an empty state message when a section has no titles', (
    WidgetTester tester,
  ) async {
    final vm = HomeViewModel(repository: _repo());
    await vm.load();

    await tester.pumpWidget(_wrap(vm));
    await tester.pump();

    expect(find.text('Trending'), findsOneWidget);
    expect(find.textContaining('No titles'), findsWidgets);
  });
}
