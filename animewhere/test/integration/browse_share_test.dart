import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide Title;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

import 'package:animewhere/app/app.dart';
import 'package:animewhere/app/theme/app_theme.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/network/http_client.dart';
import 'package:animewhere/data/repositories/catalog_repository.dart';
import 'package:animewhere/data/repositories/share_repository.dart';
import 'package:animewhere/data/sources/anilist/anilist_api.dart';
import 'package:animewhere/data/sources/jikan/jikan_api.dart';
import 'package:animewhere/data/sources/kitsu/kitsu_api.dart';
import 'package:animewhere/ui/detail/detail_view.dart';
import 'package:animewhere/ui/home/home_view_model.dart';
import 'package:animewhere/ui/share/share_service.dart';

String fixture(String name) =>
    File('test/fixtures/$name.json').readAsStringSync();

http.Client _mockApiClient() {
  return MockClient((request) async {
    http.Response ok(String body) => http.Response(
      body,
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    final host = request.url.host;
    final path = request.url.path;

    if (host.contains('jikan')) {
      if (path.endsWith('/anime/21')) return ok(fixture('jikan_anime_21'));
      if (path.contains('/top/anime')) return ok(fixture('jikan_top_anime'));
      if (path.contains('/seasons/now')) {
        return ok(fixture('jikan_seasons_now'));
      }
      if (path.contains('/seasons/upcoming')) {
        return ok(fixture('jikan_seasons_upcoming'));
      }
    }
    if (host.contains('graphql.anilist')) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final query = body['query'] as String;
      if (query.contains('Media(id:')) return ok(fixture('anilist_media'));
      if (query.contains('Page')) return ok(fixture('anilist_page'));
    }
    if (host.contains('kitsu')) {
      if (path.endsWith('/manga/5')) return ok(fixture('kitsu_manga_5'));
      if (path.contains('/manga')) return ok(fixture('kitsu_manga'));
      if (path.contains('/edge/anime')) return ok(fixture('kitsu_anime'));
    }
    return http.Response('not found', 404);
  });
}

class _RecordingShareService extends ShareService {
  _RecordingShareService() : super(repository: ShareRepository());

  final List<String> sharedUrls = [];

  @override
  Future<void> shareTitle(Title title) async {
    sharedUrls.add(repository.targetFor(title).shareUrl);
  }
}

void main() {
  testWidgets('browse -> detail -> share journey works end to end', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final shareService = _RecordingShareService();
    final httpClient = AppHttpClient(inner: _mockApiClient());
    final homeViewModel = HomeViewModel(
      repository: CatalogRepository(
        jikanApi: JikanApi(httpClient: httpClient),
        anilistApi: AniListApi(httpClient: httpClient),
        kitsuApi: KitsuApi(httpClient: httpClient),
      ),
    );
    homeViewModel.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppHttpClient>.value(value: httpClient),
          ChangeNotifierProvider<HomeViewModel>.value(value: homeViewModel),
          Provider<ShareService>.value(value: shareService),
        ],
        child: MaterialApp.router(
          theme: AppTheme.themeData,
          routerConfig: AppRouter.router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AnimeWhere'), findsOneWidget);

    await tester.tap(find.text('One Piece').first);
    await tester.pumpAndSettle();

    expect(find.byType(DetailView), findsOneWidget);
    expect(
      find.text(
        'Gol D. Roger was known as the Pirate King, the strongest and '
        'most infamous being to have sailed the Grand Line.',
      ),
      findsOneWidget,
    );
    expect(find.text('Score 87.1'), findsOneWidget);
    expect(find.text('TV'), findsOneWidget);

    await tester.tap(find.text('Share'));
    await tester.pumpAndSettle();

    expect(shareService.sharedUrls, ['https://animewhere.app/title/jikan/21']);
  });
}
