import 'package:flutter_test/flutter_test.dart';

import 'package:fluttmov/src/presentation/components/error_state_widget.dart';
import 'package:fluttmov/src/presentation/components/empty_state_widget.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ErrorStateWidget', () {
    testWidgets('exibe a mensagem e chama onRetry', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrap(
          ErrorStateWidget(
            message: 'Sem conexão com a internet.',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Sem conexão com a internet.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      expect(retried, isTrue);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('exibe a mensagem', (tester) async {
      await tester.pumpWidget(
        wrap(const EmptyStateWidget(message: 'Nenhum filme encontrado.')),
      );

      expect(find.text('Nenhum filme encontrado.'), findsOneWidget);
    });
  });
}
