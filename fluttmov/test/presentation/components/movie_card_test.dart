import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/core/theme/app_icons.dart';
import 'package:fluttmov/src/presentation/components/movie_card.dart';

import '../../helpers/fixtures.dart';

Future<void> pumpCard(WidgetTester tester, MovieCard card) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 160,
            height: 300,
            child: card,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('exibe título, ano e nota', (tester) async {
    await pumpCard(tester, MovieCard(movie: buildMovie(posterPath: null)));

    expect(find.text('Duna: Parte Dois'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('8.2'), findsOneWidget);
  });

  testWidgets('ao tocar no card chama onTap', (tester) async {
    var tapped = false;
    await pumpCard(
      tester,
      MovieCard(movie: buildMovie(posterPath: null), onTap: () => tapped = true),
    );

    await tester.tap(find.byType(MovieCard));
    expect(tapped, isTrue);
  });

  testWidgets('ao tocar no favorito chama onFavoriteTap', (tester) async {
    var tapped = false;
    await pumpCard(
      tester,
      MovieCard(
        movie: buildMovie(posterPath: null),
        onFavoriteTap: () => tapped = true,
      ),
    );

    await tester.tap(find.byIcon(AppIcons.favoriteBorder));
    expect(tapped, isTrue);
  });

  testWidgets('mostra ícone preenchido quando é favorito', (tester) async {
    await pumpCard(
      tester,
      MovieCard(
        movie: buildMovie(posterPath: null),
        isFavorite: true,
        onFavoriteTap: () {},
      ),
    );

    expect(find.byIcon(AppIcons.favorite), findsOneWidget);
  });
}
