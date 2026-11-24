import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/repository_config.dart';
import '../data/history_repository.dart';
import '../../result/data/models/product.dart';
import '../data/models/history_item.dart';

enum HistoryCategoryFilter { all, food, cosmetic }
enum HistoryStatusFilter { all, safe, needsAttention, flagged }

class HistoryFilters {
  const HistoryFilters({this.category = HistoryCategoryFilter.all, this.status = HistoryStatusFilter.all, this.startDate, this.endDate});

  final HistoryCategoryFilter category;
  final HistoryStatusFilter status;
  final DateTime? startDate;
  final DateTime? endDate;

  HistoryFilters copyWith({HistoryCategoryFilter? category, HistoryStatusFilter? status, DateTime? startDate, DateTime? endDate, bool clearDates = false}) {
    return HistoryFilters(category: category ?? this.category, status: status ?? this.status, startDate: clearDates ? null : startDate ?? this.startDate, endDate: clearDates ? null : endDate ?? this.endDate);
  }
}

List<HistoryItem> filterHistory(List<HistoryItem> items, String query, HistoryFilters filters) {
  final normalized = query.trim().toLowerCase();

  return items.where((item) {
    final matchesSearch = normalized.isEmpty || item.product.name.toLowerCase().contains(normalized) || item.product.brand.toLowerCase().contains(normalized);

    final matchesCategory = switch (filters.category) {
      HistoryCategoryFilter.all => true,
      HistoryCategoryFilter.food => item.product.category == ProductCategory.food,
      HistoryCategoryFilter.cosmetic => item.product.category == ProductCategory.cosmetic,
    };

    final matchesStatus = switch (filters.status) {
      HistoryStatusFilter.all => true,
      HistoryStatusFilter.safe => item.classification == SafetyClassification.safe,
      HistoryStatusFilter.needsAttention => item.classification == SafetyClassification.needsAttention,
      HistoryStatusFilter.flagged => item.classification == SafetyClassification.flagged,
    };

    final scanned = item.scannedAt;
    final matchesStart = filters.startDate == null || !scanned.isBefore(DateTime(filters.startDate!.year, filters.startDate!.month, filters.startDate!.day));
    final matchesEnd = filters.endDate == null || !scanned.isAfter(DateTime(filters.endDate!.year, filters.endDate!.month, filters.endDate!.day, 23, 59, 59));

    return matchesSearch && matchesCategory && matchesStatus && matchesStart && matchesEnd;
  }).toList();
}

class HistoryFiltersNotifier extends Notifier<HistoryFilters> {
  @override
  HistoryFilters build() => const HistoryFilters();

  void update(HistoryFilters filters) => state = filters;
}

final historyFiltersProvider = NotifierProvider<HistoryFiltersNotifier, HistoryFilters>(HistoryFiltersNotifier.new);

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final mode = ref.watch(repositoryModeProvider);
  return mode == RepositoryMode.mock
      ? const MockHistoryRepository()
      : const RealHistoryRepository();
});

final historyProvider = FutureProvider<List<HistoryItem>>((ref) {
  return ref.watch(historyRepositoryProvider).getHistory();
});
