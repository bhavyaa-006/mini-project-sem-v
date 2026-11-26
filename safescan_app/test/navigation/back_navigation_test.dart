import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safescan_app/core/router/routes.dart';
import 'package:safescan_app/features/history/data/history_repository.dart';
import 'package:safescan_app/features/history/presentation/history_screen.dart';
import 'package:safescan_app/features/history/providers/history_provider.dart';
import 'package:safescan_app/features/home/data/home_repository.dart';
import 'package:safescan_app/features/home/presentation/home_screen.dart';
import 'package:safescan_app/features/home/providers/home_provider.dart';
import 'package:safescan_app/features/result/data/analysis_repository.dart';
import 'package:safescan_app/features/result/providers/result_provider.dart';
import 'package:safescan_app/features/scan/data/scan_repository.dart';
import 'package:safescan_app/features/scan/presentation/scan_processing_screen.dart';
import 'package:safescan_app/features/scan/providers/scan_provider.dart';

void main() {
  testWidgets('Home to History and back preserves the Home route', (
    tester,
  ) async {
    final router = _testRouter();
    await tester.pumpWidget(_app(router));
    await tester.pump(const Duration(milliseconds: 750));

    await tester.ensureVisible(find.text('See all'));
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.text('History'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Your products.\nYour safety.'), findsOneWidget);
    router.dispose();
  });

  testWidgets('Scan result back returns to Scanner, then Home', (tester) async {
    final router = _testRouter();
    await tester.pumpWidget(_app(router));
    await tester.pump(const Duration(milliseconds: 750));

    await tester.tap(find.text('Scan Barcode'));
    await tester.pumpAndSettle();
    expect(find.text('Scanner'), findsOneWidget);

    await tester.tap(find.text('Start mock scan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('Saved report: mock-food-good'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Scanner'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Your products.\nYour safety.'), findsOneWidget);
    router.dispose();
  });

  testWidgets(
    'Back during loading cancels the mock scan and returns to Scanner',
    (tester) async {
      final router = _testRouter();
      await tester.pumpWidget(_app(router));
      await tester.pump(const Duration(milliseconds: 750));

      await tester.tap(find.text('Scan Barcode'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start mock scan'));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Processing scan'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Scanner'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Saved report: mock-food-good'), findsNothing);
      expect(find.text('Scanner'), findsOneWidget);
      router.dispose();
    },
  );

  testWidgets('Saved report opened from History returns to History', (
    tester,
  ) async {
    final router = _testRouter(initialLocation: AppRoutes.history);
    await tester.pumpWidget(_app(router));
    await tester.pump(const Duration(milliseconds: 450));

    await tester.tap(find.text('MOCK Wholegrain Breakfast Oats').first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Saved report: mock-food-good'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('History'), findsOneWidget);
    router.dispose();
  });

  testWidgets('Back closes a Home bottom sheet without leaving Home', (
    tester,
  ) async {
    final router = _testRouter();
    await tester.pumpWidget(_app(router));
    await tester.pump(const Duration(milliseconds: 750));

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('No notifications'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('No notifications'), findsNothing);
    expect(find.text('Your products.\nYour safety.'), findsOneWidget);
    router.dispose();
  });
}

Widget _app(GoRouter router) {
  return ProviderScope(
    overrides: [
      homeRepositoryProvider.overrideWithValue(const MockHomeRepository()),
      historyRepositoryProvider.overrideWithValue(
        const MockHistoryRepository(delay: Duration.zero),
      ),
      productLookupRepositoryProvider.overrideWithValue(
        const MockProductLookupRepository(delay: Duration.zero),
      ),
      analysisRepositoryProvider.overrideWithValue(
        const MockAnalysisRepository(delay: Duration.zero),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

GoRouter _testRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.barcodeScanner,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Scanner')),
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () =>
                    context.push(AppRoutes.scanProcessingPath('890100100001')),
                child: const Text('Start mock scan'),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.scanProcessing,
        builder: (context, state) =>
            ScanProcessingScreen(barcode: state.pathParameters['barcode']!),
      ),
      GoRoute(
        path: AppRoutes.productResult,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Saved report')),
          body: Center(
            child: Text('Saved report: ${state.pathParameters['id']}'),
          ),
        ),
      ),
    ],
  );
}
