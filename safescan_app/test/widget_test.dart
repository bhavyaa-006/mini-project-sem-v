import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:safescan_app/app.dart';
import 'package:safescan_app/core/services/app_start_service.dart';
import 'package:safescan_app/core/storage/secure_storage.dart';
import 'package:safescan_app/features/home/data/home_repository.dart';
import 'package:safescan_app/features/home/providers/home_provider.dart';
import 'package:safescan_app/features/home/presentation/home_screen.dart';
import 'package:safescan_app/features/scan/presentation/scan_screen.dart';
import 'package:safescan_app/features/scan/presentation/label_capture_screen.dart';
import 'package:safescan_app/core/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:safescan_app/shared/widgets/app_text_field.dart';
import 'package:safescan_app/shared/widgets/primary_button.dart';
import 'package:safescan_app/shared/widgets/status_badge.dart';
import 'package:safescan_app/shared/widgets/skeleton_loader.dart';

void main() {
  test('First launch routes to onboarding', () async {
    final storage = MockAppStorage(onboardingSeen: false, signedIn: false);
    final service = StorageAppStartService(storage);

    expect(await service.getDestination(), AppStartDestination.onboarding);
  });

  test('Completing onboarding saves the seen flag', () async {
    final storage = MockAppStorage(onboardingSeen: false, signedIn: false);
    final service = StorageAppStartService(storage);

    await service.completeOnboarding();

    expect(await service.getDestination(), AppStartDestination.login);
  });

  test('Seen onboarding and signed-out routes to login', () async {
    final storage = MockAppStorage(onboardingSeen: true, signedIn: false);
    final service = StorageAppStartService(storage);

    expect(await service.getDestination(), AppStartDestination.login);
  });

  test('Seen onboarding and signed-in routes to home', () async {
    final storage = MockAppStorage(onboardingSeen: true, signedIn: true);
    final service = StorageAppStartService(storage);

    expect(await service.getDestination(), AppStartDestination.home);
  });

  testWidgets('App starts on splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SafeScanApp()),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SafeScan'), findsOneWidget);
    expect(find.text("Know What's Inside."), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Label capture back uses scan hub when route stack is empty', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.labelScanner,
      routes: <RouteBase>[
        GoRoute(path: AppRoutes.labelScanner, builder: (context, state) => const LabelCaptureScreen()),
        GoRoute(path: AppRoutes.scanHub, builder: (context, state) => const Scaffold(body: Text('Scan hub fallback'))),
      ],
    );

    await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Scan hub fallback'), findsOneWidget);
  });

  testWidgets('Home dashboard shows loading then mock data', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeRepositoryProvider.overrideWithValue(const MockHomeRepository())],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    expect(find.byType(SkeletonLoader), findsWidgets);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Your products.\nYour safety.'), findsOneWidget);
    expect(find.text('Organic Rolled Oats'), findsOneWidget);
  });

  testWidgets('Home dashboard shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [homeRepositoryProvider.overrideWithValue(const MockEmptyHomeRepository())],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('No recent scans'), findsOneWidget);
  });

  testWidgets('Scan hub navigates to both scanner routes', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.scanHub,
      routes: <RouteBase>[
        GoRoute(path: AppRoutes.scanHub, builder: (context, state) => const ScanScreen()),
        GoRoute(path: AppRoutes.barcodeScanner, builder: (context, state) => const Scaffold(body: Text('Barcode destination'))),
        GoRoute(path: AppRoutes.labelScanner, builder: (context, state) => const Scaffold(body: Text('Label destination'))),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Scan Barcode'), findsOneWidget);
    await tester.tap(find.text('Scan Barcode'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Barcode destination'), findsOneWidget);

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AppRoutes.scanHub,
        routes: <RouteBase>[
          GoRoute(path: AppRoutes.scanHub, builder: (context, state) => const ScanScreen()),
          GoRoute(path: AppRoutes.labelScanner, builder: (context, state) => const Scaffold(body: Text('Label destination'))),
        ],
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Scan Label'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Label destination'), findsOneWidget);
  });

  testWidgets('Primary button shows loading state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PrimaryButton(label: 'Save', onPressed: null, isLoading: true),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Password field toggles visibility and status badge shows text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: <Widget>[
              AppTextField(label: 'Password', obscureText: true),
              StatusBadge(status: AppStatus.safe),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Safe'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
