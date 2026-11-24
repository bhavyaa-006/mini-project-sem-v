import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/product_image.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../result/data/models/product.dart';
import '../data/models/history_item.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Clear all history?'), content: const Text('This removes every mock scan from your history.'), actions: <Widget>[TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear all'))])) ?? false;
    if (!confirmed) return;

    await ref.read(historyRepositoryProvider).clearHistory();
    ref.invalidate(historyProvider);
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final filters = ref.watch(historyFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: <Widget>[IconButton(tooltip: 'Filter history', onPressed: () => _openFilters(context), icon: const Icon(Icons.tune)), IconButton(tooltip: 'Clear all history', onPressed: _clearAll, icon: const Icon(Icons.delete_sweep_outlined))],
      ),
      body: SafeArea(
        child: history.when(
          loading: () => const _HistorySkeleton(),
          error: (_, __) => ErrorState(message: 'History could not be loaded.', onRetry: () => ref.invalidate(historyProvider)),
          data: (items) {
            if (items.isEmpty) return const EmptyState(title: 'No scan history', message: 'Scanned products will appear here.', icon: Icons.history);

            final filtered = filterHistory(items, _search.text, filters);
            return Column(
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm), child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search product name or brand'))),
                Expanded(child: filtered.isEmpty
                    ? const EmptyState(title: 'No matching scans', message: 'Try another search or filter.', icon: Icons.search_off_outlined)
                    : ListView(padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg), children: _grouped(filtered))),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _grouped(List<HistoryItem> items) {
    final groups = <String, List<HistoryItem>>{};
    for (final item in items) {
      final date = item.scannedAt;
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => <HistoryItem>[]).add(item);
    }

    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      widgets.add(Padding(padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm), child: Text(_dateLabel(entry.key), style: AppTypography.title)));
      for (var i = 0; i < entry.value.length; i++) {
        final item = entry.value[i];
        widgets.add(Dismissible(key: ValueKey(item.id), direction: DismissDirection.endToStart, background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: AppSpacing.lg), color: AppColors.danger, child: const Icon(Icons.delete_outline, color: AppColors.white)), onDismissed: (_) async {
          await ref.read(historyRepositoryProvider).deleteHistoryItem(item.id);
          ref.invalidate(historyProvider);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Scan removed'), action: SnackBarAction(label: 'Undo', onPressed: () async {
            await ref.read(historyRepositoryProvider).addHistoryItem(item);
            ref.invalidate(historyProvider);
          })));
        }, child: _HistoryTile(item: item)));
        if (i != entry.value.length - 1) widgets.add(const SizedBox(height: AppSpacing.sm));
      }
    }
    return widgets;
  }

  String _dateLabel(String isoDate) {
    final date = DateTime.parse('$isoDate 00:00:00');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return '${date.day} ${_month(date.month)} ${date.year}';
  }

  String _month(int month) => const <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];

  void _openFilters(BuildContext context) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => _HistoryFilterSheet(ref: ref));
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final HistoryItem item;

  AppStatus get _status => switch (item.classification) {
  SafetyClassification.safe => AppStatus.safe,
  SafetyClassification.needsAttention => AppStatus.needsAttention,
  SafetyClassification.flagged => AppStatus.flagged,
  SafetyClassification.unknown => AppStatus.unableToVerify,
};

  @override
  Widget build(BuildContext context) {
    final time = '${item.scannedAt.hour.toString().padLeft(2, '0')}:${item.scannedAt.minute.toString().padLeft(2, '0')}';

    return AppCard(
      onTap: () {
        final id = switch (item.product.barcode) {
          '890100100001' => 'mock-food-good',
          '890100100004' => 'mock-cosmetic-flagged',
          '890100100003' => 'mock-cosmetic-good',
          _ => 'mock-food-good',
        };
        context.go(AppRoutes.productResultPath(id));
      },
      child: Row(
        children: <Widget>[const ProductImage(size: 64), const SizedBox(width: AppSpacing.sm), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(item.product.name, style: AppTypography.title, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: AppSpacing.xs), Text(item.product.brand, style: AppTypography.bodySmall), const SizedBox(height: AppSpacing.xs), StatusBadge(status: _status)])), const SizedBox(width: AppSpacing.sm), Column(children: <Widget>[Text('${item.safetyScore}', style: AppTypography.headline), Text(time, style: AppTypography.bodySmall)])],
      ),
    );
  }
}

class _HistoryFilterSheet extends ConsumerWidget {
  const _HistoryFilterSheet({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var filters = ref.watch(historyFiltersProvider);

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Filter history', style: AppTypography.headline),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Category', style: AppTypography.title),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: <Widget>[
                      ChoiceChip(label: const Text('All'), selected: filters.category == HistoryCategoryFilter.all, onSelected: (_) => setSheetState(() => filters = filters.copyWith(category: HistoryCategoryFilter.all))),
                      ChoiceChip(label: const Text('Food'), selected: filters.category == HistoryCategoryFilter.food, onSelected: (_) => setSheetState(() => filters = filters.copyWith(category: HistoryCategoryFilter.food))),
                      ChoiceChip(label: const Text('Cosmetic'), selected: filters.category == HistoryCategoryFilter.cosmetic, onSelected: (_) => setSheetState(() => filters = filters.copyWith(category: HistoryCategoryFilter.cosmetic))),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Safety status', style: AppTypography.title),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      ChoiceChip(label: const Text('All'), selected: filters.status == HistoryStatusFilter.all, onSelected: (_) => setSheetState(() => filters = filters.copyWith(status: HistoryStatusFilter.all))),
                      ChoiceChip(label: const Text('Safe'), selected: filters.status == HistoryStatusFilter.safe, onSelected: (_) => setSheetState(() => filters = filters.copyWith(status: HistoryStatusFilter.safe))),
                      ChoiceChip(label: const Text('Needs attention'), selected: filters.status == HistoryStatusFilter.needsAttention, onSelected: (_) => setSheetState(() => filters = filters.copyWith(status: HistoryStatusFilter.needsAttention))),
                      ChoiceChip(label: const Text('Flagged'), selected: filters.status == HistoryStatusFilter.flagged, onSelected: (_) => setSheetState(() => filters = filters.copyWith(status: HistoryStatusFilter.flagged))),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Date range', style: AppTypography.title),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: filters.startDate ?? DateTime.now());
                            if (date != null) setSheetState(() => filters = filters.copyWith(startDate: date));
                          },
                          child: Text(filters.startDate == null ? 'Start date' : '${filters.startDate!.day}/${filters.startDate!.month}/${filters.startDate!.year}'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: filters.endDate ?? DateTime.now());
                            if (date != null) setSheetState(() => filters = filters.copyWith(endDate: date));
                          },
                          child: Text(filters.endDate == null ? 'End date' : '${filters.endDate!.day}/${filters.endDate!.month}/${filters.endDate!.year}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: <Widget>[
                      Expanded(child: OutlinedButton(onPressed: () => setSheetState(() => filters = const HistoryFilters()), child: const Text('Reset'))),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(historyFiltersProvider.notifier).update(filters);
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(padding: const EdgeInsets.all(AppSpacing.md), itemCount: 5, separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm), itemBuilder: (_, __) => const SkeletonLoader(width: double.infinity, height: 100));
  }
}
