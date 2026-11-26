import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/models/product.dart';
import '../data/models/safety_models.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/services/personal_warning_service.dart';
import '../providers/result_provider.dart';

class IngredientDetailScreen extends ConsumerWidget {
  const IngredientDetailScreen({required this.routeId, super.key});

  final String routeId;

  ({String productId, String ingredientName}) _decode() {
    final decoded = Uri.decodeComponent(routeId);
    final separator = decoded.indexOf('/');
    if (separator < 0) return (productId: decoded, ingredientName: '');
    return (
      productId: decoded.substring(0, separator),
      ingredientName: Uri.decodeComponent(decoded.substring(separator + 1)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = _decode();
    final result = ref.watch(scanResultProvider(ids.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: 'Back to ingredient list',
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: result.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('Ingredient details could not be loaded.'),
          ),
          data: (scan) {
            Ingredient? ingredient;
            if (scan != null) {
              for (final item in scan.ingredients) {
                if (item.name == ids.ingredientName) {
                  ingredient = item;
                  break;
                }
              }
            }

            if (ingredient == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.help_outline, size: 64),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Ingredient not found',
                        style: AppTypography.headline,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Back to ingredients'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final status = switch (ingredient.classification) {
              SafetyClassification.safe => AppStatus.safe,
              SafetyClassification.needsAttention => AppStatus.needsAttention,
              SafetyClassification.flagged => AppStatus.flagged,
              SafetyClassification.unknown => AppStatus.unableToVerify,
            };

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(ingredient.name, style: AppTypography.headline),
                      const SizedBox(height: AppSpacing.sm),
                      StatusBadge(status: status),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Purpose', style: AppTypography.title),
                            const SizedBox(height: AppSpacing.sm),
                            Text(ingredient.purpose, style: AppTypography.body),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Potential concerns',
                              style: AppTypography.title,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            if (ingredient.concerns.isEmpty)
                              Text(
                                'No specific concerns listed.',
                                style: AppTypography.bodySmall,
                              )
                            else
                              for (final concern in ingredient.concerns)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    '• $concern',
                                    style: AppTypography.body,
                                  ),
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Warnings', style: AppTypography.title),
                            const SizedBox(height: AppSpacing.sm),
                            if (ingredient.warnings.isEmpty)
                              Text(
                                'No additional mock warnings.',
                                style: AppTypography.bodySmall,
                              )
                            else
                              for (final warning in ingredient.warnings)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    '• $warning',
                                    style: AppTypography.body,
                                  ),
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ref
                          .watch(profileProvider)
                          .when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (profile) {
                              const service = PersonalWarningService();
                              if (!service.isProfileComplete(profile)) {
                                return AppCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Personal warning',
                                        style: AppTypography.title,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Complete your profile to show personalised ingredient warnings.',
                                        style: AppTypography.bodySmall,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      TextButton(
                                        onPressed: () =>
                                            context.push(AppRoutes.profile),
                                        child: const Text('Go to Profile'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final currentIngredient = ingredient!;
                              final warnings = service.findWarnings(
                                profile,
                                <Ingredient>[currentIngredient],
                              );
                              if (warnings.isEmpty) {
                                return AppCard(
                                  child: Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: AppColors.success,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          'No personal warning matched this ingredient.',
                                          style: AppTypography.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Personal warning',
                                      style: AppTypography.title,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    for (final warning in warnings)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: AppSpacing.xs,
                                        ),
                                        child: Text(
                                          '${warning.title}: ${warning.message}',
                                          style: AppTypography.bodySmall,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                      const SizedBox(height: AppSpacing.md),
                      _VerificationCard(status: ingredient.verificationStatus),
                    ],
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

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final badge = switch (status) {
      VerificationStatus.verified => AppStatus.compliant,
      VerificationStatus.uncertain => AppStatus.unableToVerify,
      VerificationStatus.missing => AppStatus.informationMissing,
      VerificationStatus.unableToVerify => AppStatus.unableToVerify,
    };

    final explanation = switch (status) {
      VerificationStatus.verified =>
        'Verified means the mock label text clearly supports this ingredient entry.',
      VerificationStatus.uncertain =>
        'Uncertain means the source or classification could not be fully confirmed.',
      VerificationStatus.missing =>
        'Missing means ingredient verification data is not available.',
      VerificationStatus.unableToVerify =>
        'Unable to verify means the available information is insufficient to confirm this entry.',
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text('Data confidence', style: AppTypography.title),
              ),
              StatusBadge(status: badge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(explanation, style: AppTypography.bodySmall),
          ),
        ],
      ),
    );
  }
}
