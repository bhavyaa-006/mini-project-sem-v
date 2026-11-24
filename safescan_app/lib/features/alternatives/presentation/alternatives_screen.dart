import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../data/models/alternative_product.dart';
import '../providers/alternatives_provider.dart';

class AlternativesScreen extends ConsumerWidget {
  const AlternativesScreen({this.productId, super.key});

  final String? productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alternatives = ref.watch(alternativesProvider(productId ?? 'all'));
    final filters = ref.watch(alternativeFiltersProvider);
    final selected = ref.watch(selectedAlternativesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alternatives'),
        leading: productId == null ? null : IconButton(tooltip: 'Back', onPressed: () => context.go(AppRoutes.productResultPath(productId!)), icon: const Icon(Icons.arrow_back)),
        actions: <Widget>[IconButton(tooltip: 'Filter alternatives', onPressed: () => _openFilters(context, ref), icon: const Icon(Icons.tune))],
      ),
      body: alternatives.when(
        loading: () => const _AlternativesSkeleton(),
        error: (_, __) => ErrorState(message: 'Alternatives could not be loaded.', onRetry: () => ref.invalidate(alternativesProvider(productId ?? 'all'))),
        data: (items) {
          final filtered = filterAlternatives(items, filters);
          if (filtered.isEmpty) {
            return const EmptyState(title: 'No safer alternatives found', message: 'Try lowering the minimum score or changing the category filter.', icon: Icons.compare_arrows);
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 720 ? 2 : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md, mainAxisExtent: 170),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isSelected = selected.where((value) => value.product.barcode == item.product.barcode).isNotEmpty;
                        return _AlternativeCard(item: item, selected: isSelected, onSelected: () {
                          final accepted = ref.read(selectedAlternativesProvider.notifier).toggle(item);
                          if (!accepted && !isSelected) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You can compare up to 3 alternatives.')));
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              if (selected.isNotEmpty)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: selected.length >= 2
                            ? () => context.go(AppRoutes.alternativesCompare)
                            : null,
                        icon: const Icon(Icons.compare_arrows),
                        label: Text('Compare ${selected.length} selected'),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openFilters(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (sheetContext) => _AlternativeFilterSheet(ref: ref));
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.item, required this.selected, required this.onSelected});

  final AlternativeProduct item;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onSelected,
      padding: EdgeInsets.zero,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const ProductImage(size: 76), const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(item.product.name, style: AppTypography.title, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: AppSpacing.xs), Text(item.product.brand, style: AppTypography.bodySmall), const SizedBox(height: AppSpacing.sm), Text(item.reason, style: AppTypography.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis)])), const SizedBox(width: AppSpacing.sm), ScoreRing(score: item.safetyScore, label: 'Score')]),
          ),
          Positioned(top: AppSpacing.sm, right: AppSpacing.sm, child: Checkbox(value: selected, onChanged: (_) => onSelected(), shape: const CircleBorder())),
        ],
      ),
    );
  }
}

class _AlternativeFilterSheet extends ConsumerWidget {
  const _AlternativeFilterSheet({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var filters = ref.watch(alternativeFiltersProvider);

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('Filter alternatives', style: AppTypography.headline), const SizedBox(height: AppSpacing.lg), Text('Category', style: AppTypography.title), const SizedBox(height: AppSpacing.sm), Wrap(spacing: AppSpacing.sm, children: <Widget>[ChoiceChip(label: const Text('All'), selected: filters.category == AlternativeCategoryFilter.all, onSelected: (_) => setSheetState(() => filters = filters.copyWith(category: AlternativeCategoryFilter.all))), ChoiceChip(label: const Text('Food'), selected: filters.category == AlternativeCategoryFilter.food, onSelected: (_) => setSheetState(() => filters = filters.copyWith(category: AlternativeCategoryFilter.food))), ChoiceChip(label: const Text('Cosmetic'), selected: filters.category == AlternativeCategoryFilter.cosmetic, onSelected: (_) => setSheetState(() => filters = filters.copyWith(category: AlternativeCategoryFilter.cosmetic)))]), const SizedBox(height: AppSpacing.lg), Row(children: <Widget>[Text('Minimum score', style: AppTypography.title), const Spacer(), Text('${filters.minimumScore}')]), Slider(value: filters.minimumScore.toDouble(), min: 0, max: 100, divisions: 10, onChanged: (value) => setSheetState(() => filters = filters.copyWith(minimumScore: value.round()))), const SizedBox(height: AppSpacing.sm), Row(children: <Widget>[Text('Sort', style: AppTypography.title), const Spacer(), DropdownButton<AlternativeSort>(value: filters.sort, onChanged: (value) { if (value != null) setSheetState(() => filters = filters.copyWith(sort: value)); }, items: const <DropdownMenuItem<AlternativeSort>>[DropdownMenuItem(value: AlternativeSort.scoreDesc, child: Text('Highest score')), DropdownMenuItem(value: AlternativeSort.scoreAsc, child: Text('Lowest score'))])]), const SizedBox(height: AppSpacing.lg), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { ref.read(alternativeFiltersProvider.notifier).update(filters); Navigator.of(context).pop(); }, child: const Text('Apply filters'))) ]),
          ),
        );
      },
    );
  }
}

class _AlternativesSkeleton extends StatelessWidget {
  const _AlternativesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(padding: const EdgeInsets.all(AppSpacing.md), itemCount: 4, separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md), itemBuilder: (_, __) => const SkeletonLoader(width: double.infinity, height: 170));
  }
}
