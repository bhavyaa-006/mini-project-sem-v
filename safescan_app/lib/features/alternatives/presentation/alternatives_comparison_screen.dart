import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/models/alternative_product.dart';
import '../providers/alternatives_provider.dart';

class AlternativesComparisonScreen extends ConsumerWidget {
  const AlternativesComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedAlternativesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare alternatives'),
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: selected.length < 2
          ? const EmptyState(
              title: 'Select at least 2',
              message: 'Choose two or three alternatives to compare.',
            )
          : SafeArea(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final item in selected)
                      SizedBox(
                        width: 260,
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: _ComparisonCard(item: item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.item});

  final AlternativeProduct item;

  @override
  Widget build(BuildContext context) {
    final category = item.product.category.name;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.product.name,
            style: AppTypography.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(item.product.brand, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              category.toUpperCase(),
              style: AppTypography.label.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Safety score', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          Text('${item.safetyScore}/100', style: AppTypography.headline),
          const SizedBox(height: AppSpacing.lg),
          Text('Nutri-Score', style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.product.category.name == 'food'
                ? 'MOCK: B or better'
                : 'Not applicable',
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Key ingredient differences', style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
          Text(item.reason, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          const StatusBadge(status: AppStatus.safe),
        ],
      ),
    );
  }
}
