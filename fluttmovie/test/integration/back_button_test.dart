import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttmovie/core/di/service_locator.dart';
import 'package:fluttmovie/features/movies/detail/detail_screen.dart';
import 'package:fluttmovie/features/movies/movie_list/movie_list_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('fluttmovie_back_test');
    Hive.init(dir.path);
    await ServiceLocator.init();
  });

  Future<GoRouter> buildRouter({String initialLocation = '/list'}) async {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/list',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => context.push('/movie/detail/1'),
                  child: const Text('IR_DETALHE'),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/catalog',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () => context.push('/movie/28'),
                  child: const Text('IR_CATALOGO'),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/movie/:genreId',
          builder: (_, state) => MovieListScreen(
            genreId: int.parse(state.pathParameters['genreId']!),
          ),
        ),
        GoRoute(
          path: '/movie/detail/:movieId',
          builder: (_, state) => DetailScreen(
            movieId: int.parse(state.pathParameters['movieId']!),
          ),
        ),
      ],
    );
  }

  testWidgets('botão de voltar da tela de detalhes retorna à página anterior',
      (tester) async {
    final router = await buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('IR_DETALHE'));
    await tester.pumpAndSettle();
    expect(find.byType(DetailScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(DetailScreen), findsNothing);
    expect(find.text('IR_DETALHE'), findsOneWidget);
  });

  testWidgets('botão de voltar da tela de catálogo retorna à página anterior',
      (tester) async {
    final router = await buildRouter(initialLocation: '/catalog');
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('IR_CATALOGO'));
    await tester.pumpAndSettle();
    expect(find.byType(MovieListScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(MovieListScreen), findsNothing);
    expect(find.text('IR_CATALOGO'), findsOneWidget);
  });
}
