import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/repository_config.dart';
import '../data/alternatives_repository.dart';
import '../data/models/alternative_product.dart';
import '../../result/data/models/product.dart';

enum AlternativeCategoryFilter { all, food, cosmetic }
enum AlternativeSort { scoreDesc, scoreAsc }

class AlternativeFilters {
  const AlternativeFilters({this.category = AlternativeCategoryFilter.all, this.minimumScore = 0, this.sort = AlternativeSort.scoreDesc});

  final AlternativeCategoryFilter category;
  final int minimumScore;
  final AlternativeSort sort;

  AlternativeFilters copyWith({AlternativeCategoryFilter? category, int? minimumScore, AlternativeSort? sort}) {
    return AlternativeFilters(category: category ?? this.category, minimumScore: minimumScore ?? this.minimumScore, sort: sort ?? this.sort);
  }
}

List<AlternativeProduct> filterAlternatives(List<AlternativeProduct> items, AlternativeFilters filters) {
  final filtered = items.where((item) {
    final categoryMatches = switch (filters.category) {
      AlternativeCategoryFilter.all => true,
      AlternativeCategoryFilter.food => item.product.category == ProductCategory.food,
      AlternativeCategoryFilter.cosmetic => item.product.category == ProductCategory.cosmetic,
    };
    return categoryMatches && item.safetyScore >= filters.minimumScore;
  }).toList();

  filtered.sort((a, b) => filters.sort == AlternativeSort.scoreDesc
      ? b.safetyScore.compareTo(a.safetyScore)
      : a.safetyScore.compareTo(b.safetyScore));
  return filtered;
}

class AlternativeFiltersNotifier extends Notifier<AlternativeFilters> {
  @override
  AlternativeFilters build() => const AlternativeFilters();

  void update(AlternativeFilters filters) => state = filters;
}

final alternativeFiltersProvider = NotifierProvider<AlternativeFiltersNotifier, AlternativeFilters>(AlternativeFiltersNotifier.new);

final selectedAlternativesProvider = NotifierProvider<SelectedAlternativesNotifier, List<AlternativeProduct>>(SelectedAlternativesNotifier.new);

class SelectedAlternativesNotifier extends Notifier<List<AlternativeProduct>> {
  @override
  List<AlternativeProduct> build() => <AlternativeProduct>[];

  bool toggle(AlternativeProduct item) {
    if (state.where((selected) => selected.product.barcode == item.product.barcode).isNotEmpty) {
      state = state.where((selected) => selected.product.barcode != item.product.barcode).toList();
      return true;
    }
    if (state.length >= 3) return false;
    state = <AlternativeProduct>[...state, item];
    return true;
  }

  void clear() => state = <AlternativeProduct>[];
}


final alternativesRepositoryProvider = Provider<AlternativesRepository>((ref) {
  final mode = ref.watch(repositoryModeProvider);
  return mode == RepositoryMode.mock
      ? const MockAlternativesRepository()
      : const RealAlternativesRepository();
});

final alternativesProvider = FutureProvider.family<List<AlternativeProduct>, String>((ref, productId) {
  return ref.watch(alternativesRepositoryProvider).getAlternatives(productId);
});
