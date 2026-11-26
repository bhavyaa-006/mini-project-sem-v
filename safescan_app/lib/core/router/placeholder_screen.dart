import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'routes.dart';

class RoutePlaceholderScreen extends StatelessWidget {
  const RoutePlaceholderScreen({
    required this.title,
    required this.buildStep,
    this.details,
    this.icon = Icons.construction_outlined,
    this.actionLabel,
    this.actionRoute,
    this.debugOnlyAction = false,
    super.key,
  });

  final String title;
  final String buildStep;
  final String? details;
  final IconData icon;
  final String? actionLabel;
  final String? actionRoute;
  final bool debugOnlyAction;

  @override
  Widget build(BuildContext context) {
    final showAction =
        actionLabel != null &&
        actionRoute != null &&
        (!debugOnlyAction || kDebugMode);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: AppCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(icon, size: 64, color: AppColors.primary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppTypography.headline,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          buildStep,
                          textAlign: TextAlign.center,
                          style: AppTypography.body,
                        ),
                        if (details != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            details!,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                        if (showAction) ...<Widget>[
                          const SizedBox(height: AppSpacing.lg),
                          PrimaryButton(
                            label: actionLabel!,
                            icon: Icons.route_outlined,
                            onPressed: () => context.push(actionRoute!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DebugRouteListScreen extends ConsumerWidget {
  const DebugRouteListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routes = <String, String>{
      'Splash': AppRoutes.splash,
      'Onboarding': AppRoutes.onboarding,
      'Login': AppRoutes.login,
      'Register': AppRoutes.register,
      'Forgot password': AppRoutes.forgotPassword,
      'Home': AppRoutes.home,
      'Scan hub': AppRoutes.scanHub,
      'Barcode scanner': AppRoutes.barcodeScanner,
      'Label scanner': AppRoutes.labelScanner,
      'Scan processing': AppRoutes.scanProcessing,
      'Product result': AppRoutes.productResultPath('example-product'),
      'Ingredient detail': AppRoutes.ingredientDetailPath('example-ingredient'),
      'Alternatives': AppRoutes.alternatives,
      'History': AppRoutes.history,
      'Profile': AppRoutes.profile,
      'Edit profile': AppRoutes.editProfile,
      'PDF report': AppRoutes.pdfReport,
      'Widget gallery': AppRoutes.widgetGallery,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Debug route list')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: routes.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final entry = routes.entries.elementAt(index);
            return AppCard(
              onTap: () => context.push(entry.value),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(entry.key, style: AppTypography.title),
                        const SizedBox(height: AppSpacing.xs),
                        Text(entry.value, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
