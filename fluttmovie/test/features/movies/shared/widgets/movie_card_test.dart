import 'package:fluttmovie/core/theme/app_theme.dart';
import 'package:fluttmovie/features/movies/shared/widgets/movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 160, height: 280, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('exibe título, nota e gênero', (tester) async {
    await tester.pumpWidget(
      wrap(
        MovieCard(
          movie: buildMovie(1, title: 'Filme', genreIds: const [28]),
          genreName: 'Ação',
        ),
      ),
    );

    expect(find.text('Filme 1'), findsOneWidget);
    expect(find.text('7.5'), findsOneWidget);
    expect(find.text('Ação • 2024'), findsOneWidget);
  });

  testWidgets('usa fallback quando não há gênero', (tester) async {
    await tester.pumpWidget(
      wrap(MovieCard(movie: buildMovie(1))),
    );

    expect(find.text('Filme • 2024'), findsOneWidget);
  });

  testWidgets('dispara onTap ao tocar', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        MovieCard(
          movie: buildMovie(1),
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(MovieCard));
    expect(tapped, isTrue);
  });
}
