import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safescan_app/features/profile/data/profile_repository.dart';
import 'package:safescan_app/features/profile/providers/profile_provider.dart';
import 'package:safescan_app/features/result/data/analysis_repository.dart';
import 'package:safescan_app/features/result/presentation/result_screen.dart';
import 'package:safescan_app/features/result/providers/result_provider.dart';
import 'package:safescan_app/shared/widgets/nutri_score_badge.dart';
import 'package:safescan_app/shared/widgets/score_ring.dart';

void main() {
  testWidgets('Food result shows Nutri-Score and not cosmetic score', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analysisRepositoryProvider.overrideWithValue(const MockAnalysisRepository(delay: Duration.zero)),
          profileRepositoryProvider.overrideWithValue(const MockProfileRepository(delay: Duration.zero)),
        ],
        child: const MaterialApp(home: ResultScreen(id: 'mock-food-good')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Nutri-Score'), findsOneWidget);
    expect(find.byType(NutriScoreBadge), findsOneWidget);
    expect(find.text('Cosmetic Safety Score'), findsNothing);
  });

  testWidgets('Cosmetic result shows Cosmetic Safety Score and not Nutri-Score', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analysisRepositoryProvider.overrideWithValue(const MockAnalysisRepository(delay: Duration.zero)),
          profileRepositoryProvider.overrideWithValue(const MockProfileRepository(delay: Duration.zero)),
        ],
        child: const MaterialApp(home: ResultScreen(id: 'mock-cosmetic-good')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Cosmetic Safety Score'), findsOneWidget);
    expect(find.byType(ScoreRing), findsWidgets);
    expect(find.text('Nutri-Score'), findsNothing);
  });

  testWidgets('Long mock product name stays in a scrollable layout', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analysisRepositoryProvider.overrideWithValue(const MockAnalysisRepository(delay: Duration.zero)),
          profileRepositoryProvider.overrideWithValue(const MockProfileRepository(delay: Duration.zero)),
        ],
        child: const MaterialApp(home: ResultScreen(id: 'mock-food-good')),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
