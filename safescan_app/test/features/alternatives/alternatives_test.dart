import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/alternatives/data/alternatives_repository.dart';
import 'package:safescan_app/features/alternatives/data/models/alternative_product.dart';
import 'package:safescan_app/features/alternatives/providers/alternatives_provider.dart';
import 'package:safescan_app/features/result/data/models/product.dart';

void main() {
  late List<AlternativeProduct> items;

  setUp(() async {
    items = await const MockAlternativesRepository(delay: Duration.zero).getAlternatives('mock-result');
  });

  test('category, minimum score and sorting filters work', () {
    final food = filterAlternatives(items, const AlternativeFilters(category: AlternativeCategoryFilter.food, minimumScore: 90, sort: AlternativeSort.scoreDesc));
    expect(food, isNotEmpty);
    expect(food.every((item) => item.product.category == ProductCategory.food), isTrue);
    expect(food.every((item) => item.safetyScore >= 90), isTrue);

    expect(filterAlternatives(items, const AlternativeFilters(minimumScore: 99)).isEmpty, isTrue);

    final ascending = filterAlternatives(items, const AlternativeFilters(sort: AlternativeSort.scoreAsc));
    expect(ascending.first.safetyScore <= ascending.last.safetyScore, isTrue);
  });

  test('comparison selection allows two and three items but rejects a fourth', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(selectedAlternativesProvider.notifier);

    expect(notifier.toggle(items[0]), isTrue);
    expect(notifier.toggle(items[1]), isTrue);
    expect(container.read(selectedAlternativesProvider), hasLength(2));

    expect(notifier.toggle(items[2]), isTrue);
    expect(container.read(selectedAlternativesProvider), hasLength(3));

    expect(notifier.toggle(items[3]), isFalse);
    expect(container.read(selectedAlternativesProvider), hasLength(3));

    notifier.toggle(items[0]);
    expect(container.read(selectedAlternativesProvider), hasLength(2));
  });
}
