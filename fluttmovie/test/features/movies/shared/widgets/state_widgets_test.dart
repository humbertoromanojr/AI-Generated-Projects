import 'package:fluttmovie/core/theme/app_theme.dart';
import 'package:fluttmovie/features/movies/shared/widgets/state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ErrorState exibe a mensagem e o botão de retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ErrorState(
            message: 'Erro de teste.',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('Erro de teste.'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    expect(retried, isTrue);
  });

  testWidgets('ErrorState não mostra botão quando onRetry é nulo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: ErrorState(message: 'Erro de teste.')),
      ),
    );

    expect(find.text('Tentar novamente'), findsNothing);
  });

  testWidgets('EmptyState exibe a mensagem', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: EmptyState(message: 'Nada por aqui.')),
      ),
    );

    expect(find.text('Nada por aqui.'), findsOneWidget);
  });
}
