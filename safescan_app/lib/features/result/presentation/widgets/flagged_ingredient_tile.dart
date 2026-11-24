import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/safety_models.dart';

class FlaggedIngredientTile extends StatelessWidget {
  const FlaggedIngredientTile({required this.ingredient, required this.productId, super.key});

  final Ingredient ingredient;
  final String productId;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.go(AppRoutes.ingredientDetailPath('$productId/${ingredient.name}')),
      child: Row(
        children: <Widget>[
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(ingredient.name, style: AppTypography.title), const SizedBox(height: AppSpacing.xs), Text(ingredient.purpose, style: AppTypography.bodySmall)])),
          const SizedBox(width: AppSpacing.sm),
          const StatusBadge(status: AppStatus.flagged),
        ],
      ),
    );
  }
}
