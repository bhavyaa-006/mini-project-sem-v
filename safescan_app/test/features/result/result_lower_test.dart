import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safescan_app/features/result/data/models/mock_scan_data.dart';
import 'package:safescan_app/features/result/presentation/widgets/ingredient_summary_card.dart';
import 'package:safescan_app/features/result/presentation/widgets/legal_metrology_card.dart';
import 'package:safescan_app/features/result/presentation/widgets/verified_uncertain_section.dart';
import 'package:safescan_app/features/result/presentation/widgets/why_score_section.dart';

void main() {
  testWidgets('compliant legal card renders overall compliant status', (tester) async {
    final result = buildMockScanResults()['890100100001']!;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: LegalMetrologyCard(legal: result.legalMetrology)))));

    expect(find.text('Legal Metrology'), findsOneWidget);
    expect(find.text('Compliant'), findsWidgets);
  });

  testWidgets('missing legal card renders missing and unavailable values', (tester) async {
    final result = buildMockScanResults()['890100100005']!;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: LegalMetrologyCard(legal: result.legalMetrology)))));

    expect(find.text('Information missing'), findsWidgets);
    expect(find.text('Not available'), findsWidgets);
  });

  testWidgets('non-compliant legal card renders non-compliant status', (tester) async {
    final result = buildMockScanResults()['890100100006']!;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: LegalMetrologyCard(legal: result.legalMetrology)))));

    expect(find.text('Non-compliant'), findsWidgets);
  });

  testWidgets('why, verified and ingredient sections render', (tester) async {
    final result = buildMockScanResults()['890100100003']!;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(children: <Widget>[
                WhyScoreSection(explanation: result.explanation),
                VerifiedUncertainSection(explanation: result.explanation),
                IngredientSummaryCard(ingredients: result.ingredients, productId: result.id),
              ]),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Why this score?'), findsOneWidget);
    expect(find.text('Verified vs uncertain'), findsOneWidget);
    expect(find.text('View all ingredients'), findsOneWidget);
  });
}
