import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding/onboarding_screen.dart';
import '../../features/result/presentation/ingredient_detail_screen.dart';
import '../../features/result/presentation/ingredient_list_screen.dart';
import '../../features/alternatives/presentation/alternatives_comparison_screen.dart';
import '../../features/alternatives/presentation/alternatives_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/scan/presentation/barcode_scanner_screen.dart';
import '../../features/scan/presentation/label_capture_screen.dart';
import '../../features/scan/presentation/scan_processing_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/report/presentation/report_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/scan/presentation/scan_screen.dart';
import '../../features/scan/presentation/widget_gallery_screen.dart';
import 'placeholder_screen.dart';
import 'routes.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    observers: <NavigatorObserver>[appRouteObserver],
    redirect: (context, state) {
      final auth = ref.watch(authProvider);
      final location = state.uri.path;

      if (auth.status == AuthStatus.loading) return null;

      const authRoutes = <String>{
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      };

      if (auth.status == AuthStatus.signedIn && authRoutes.contains(location)) {
        return AppRoutes.home;
      }

      if (auth.status == AuthStatus.signedOut) {
        const publicRoutes = <String>{
          AppRoutes.splash,
          AppRoutes.onboarding,
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.forgotPassword,
        };
        if (!publicRoutes.contains(location)) return AppRoutes.login;
      }

      return null;
    },
    errorBuilder: (context, state) => RoutePlaceholderScreen(
      title: 'Page not found',
      buildStep: '404 / error page — navigation only',
      details: 'No route matches ${state.uri.path}.',
      icon: Icons.search_off_outlined,
    ),
    routes: <RouteBase>[
      _route(AppRoutes.splash, AppRoutes.splashName, const SplashScreen()),
      _route(
        AppRoutes.onboarding,
        AppRoutes.onboardingName,
        const OnboardingScreen(),
      ),
      _route(AppRoutes.login, AppRoutes.loginName, const LoginScreen()),
      _route(
        AppRoutes.register,
        AppRoutes.registerName,
        const RegisterScreen(),
      ),
      _route(
        AppRoutes.forgotPassword,
        AppRoutes.forgotPasswordName,
        const ForgotPasswordScreen(),
      ),
      _route(AppRoutes.home, AppRoutes.homeName, const HomeScreen()),
      _route(AppRoutes.scanHub, AppRoutes.scanHubName, const ScanScreen()),
      _route(
        AppRoutes.barcodeScanner,
        AppRoutes.barcodeScannerName,
        const BarcodeScannerScreen(),
      ),
      _route(
        AppRoutes.labelScanner,
        AppRoutes.labelScannerName,
        const LabelCaptureScreen(),
      ),
      GoRoute(
        name: AppRoutes.scanProcessingName,
        path: AppRoutes.scanProcessing,
        pageBuilder: (context, state) => _transition(
          context,
          state,
          ScanProcessingScreen(barcode: state.pathParameters['barcode'] ?? ''),
        ),
      ),
      GoRoute(
        name: AppRoutes.productResultName,
        path: AppRoutes.productResult,
        pageBuilder: (context, state) => _transition(
          context,
          state,
          ResultScreen(id: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        name: AppRoutes.ingredientListName,
        path: AppRoutes.ingredientList,
        pageBuilder: (context, state) => _transition(
          context,
          state,
          IngredientListScreen(productId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        name: AppRoutes.ingredientDetailName,
        path: AppRoutes.ingredientDetail,
        pageBuilder: (context, state) => _transition(
          context,
          state,
          IngredientDetailScreen(routeId: state.pathParameters['id'] ?? ''),
        ),
      ),
      _route(
        AppRoutes.alternatives,
        AppRoutes.alternativesName,
        const AlternativesScreen(),
      ),
      GoRoute(
        name: AppRoutes.alternativesForProductName,
        path: AppRoutes.alternativesForProduct,
        pageBuilder: (context, state) => _transition(
          context,
          state,
          AlternativesScreen(productId: state.pathParameters['id']),
        ),
      ),
      _route(
        AppRoutes.alternativesCompare,
        AppRoutes.alternativesCompareName,
        const AlternativesComparisonScreen(),
      ),
      _route(AppRoutes.history, AppRoutes.historyName, const HistoryScreen()),
      _route(AppRoutes.profile, AppRoutes.profileName, const ProfileScreen()),
      _route(
        AppRoutes.editProfile,
        AppRoutes.editProfileName,
        const EditProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.pdfReportName,
        path: AppRoutes.pdfReport,
        pageBuilder: (context, state) => _transition(
          context,
          state,
          ReportScreen(productId: state.pathParameters['id'] ?? ''),
        ),
      ),
      if (kDebugMode) ...<RouteBase>[
        _route(
          AppRoutes.debugRoutes,
          AppRoutes.debugRoutesName,
          const DebugRouteListScreen(),
        ),
        _route(
          AppRoutes.widgetGallery,
          AppRoutes.widgetGalleryName,
          const WidgetGalleryScreen(),
        ),
      ],
    ],
  );
});

GoRoute _route(String path, String name, Widget child) {
  return GoRoute(
    name: name,
    path: path,
    pageBuilder: (context, state) => _transition(context, state, child),
  );
}

CustomTransitionPage<void> _transition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.03, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
