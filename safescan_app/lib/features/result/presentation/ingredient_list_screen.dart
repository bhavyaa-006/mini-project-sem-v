import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/models/product.dart';
import '../data/models/safety_models.dart';
import '../providers/result_provider.dart';
import 'ingredient_filter.dart';

class IngredientListScreen extends ConsumerStatefulWidget {
  const IngredientListScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<IngredientListScreen> createState() =>
      _IngredientListScreenState();
}

class _IngredientListScreenState extends ConsumerState<IngredientListScreen> {
  IngredientFilter _filter = IngredientFilter.all;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(scanResultProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: 'Back to result',
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: result.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('Ingredient data could not be loaded.')),
          data: (scan) {
            if (scan == null) {
              return const EmptyState(
                title: 'No ingredient data',
                message:
                    'This product does not have any ingredient information.',
              );
            }

            if (scan.ingredients.isEmpty) {
              return const EmptyState(
                title: 'No ingredient data',
                message: 'This mock result has no ingredient list yet.',
              );
            }

            final filtered = filterIngredients(
              scan.ingredients,
              _filter,
              _search.text,
            );

            return LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search ingredients',
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        children: <Widget>[
                          for (final filter in IngredientFilter.values)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.sm,
                              ),
                              child: ChoiceChip(
                                label: Text(switch (filter) {
                                  IngredientFilter.all => 'All',
                                  IngredientFilter.safe => 'Safe',
                                  IngredientFilter.needsAttention =>
                                    'Needs attention',
                                  IngredientFilter.flagged => 'Flagged',
                                }),
                                selected: _filter == filter,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: filtered.isEmpty
                          ? const EmptyState(
                              title: 'No matching ingredients',
                              message: 'Try another filter or search term.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final ingredient = filtered[index];
                                return _IngredientTile(
                                  ingredient: ingredient,
                                  productId: widget.productId,
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.ingredient, required this.productId});

  final Ingredient ingredient;
  final String productId;

  @override
  Widget build(BuildContext context) {
    final status = switch (ingredient.classification) {
      SafetyClassification.safe => AppStatus.safe,
      SafetyClassification.needsAttention => AppStatus.needsAttention,
      SafetyClassification.flagged => AppStatus.flagged,
      SafetyClassification.unknown => AppStatus.unableToVerify,
    };

    return AppCard(
      onTap: () => context.push(
        AppRoutes.ingredientDetailPath(
          '${productId}/${Uri.encodeComponent(ingredient.name)}',
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ingredient.name,
                  style: AppTypography.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(ingredient.purpose, style: AppTypography.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(status: status),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
