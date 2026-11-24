import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safescan_app/features/result/data/analysis_repository.dart';
import 'package:safescan_app/features/result/presentation/result_screen.dart';
import 'package:safescan_app/features/result/providers/result_provider.dart';

void main() {
  testWidgets('unknown result shows a retryable unavailable state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analysisRepositoryProvider.overrideWithValue(
            const MockAnalysisRepository(delay: Duration.zero),
          ),
        ],
        child: const MaterialApp(home: ResultScreen(id: 'unknown-result')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This product result is not available.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
