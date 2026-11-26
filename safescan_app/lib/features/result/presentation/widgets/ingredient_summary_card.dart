import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/product.dart';
import '../../data/models/safety_models.dart';

class IngredientSummaryCard extends ConsumerWidget {
  const IngredientSummaryCard({
    required this.ingredients,
    required this.productId,
    super.key,
  });

  final List<Ingredient> ingredients;
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var safe = 0;
    var attention = 0;
    var flagged = 0;

    for (final ingredient in ingredients) {
      switch (ingredient.classification) {
        case SafetyClassification.safe:
          safe++;
        case SafetyClassification.needsAttention:
          attention++;
        case SafetyClassification.flagged:
          flagged++;
        case SafetyClassification.unknown:
          attention++;
      }
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Ingredients', style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          if (ingredients.isEmpty)
            Text(
              'Ingredient data is not available for this mock result.',
              style: AppTypography.bodySmall,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final counts = <Widget>[
                  StatusBadge(status: AppStatus.safe),
                  StatusBadge(status: AppStatus.needsAttention),
                  StatusBadge(status: AppStatus.flagged),
                ];
                final labels = <String>[
                  '$safe Safe',
                  '$attention Needs attention',
                  '$flagged Flagged',
                ];

                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (var i = 0; i < counts.length; i++)
                      _CountBadge(label: labels[i], badge: counts[i]),
                  ],
                );
              },
            ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'View all ingredients',
            icon: Icons.list_alt_outlined,
            onPressed: () =>
                context.push(AppRoutes.ingredientListPath(productId)),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label, required this.badge});

  final String label;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: AppTypography.label),
        const SizedBox(width: AppSpacing.xs),
        badge,
      ],
    );
  }
}
