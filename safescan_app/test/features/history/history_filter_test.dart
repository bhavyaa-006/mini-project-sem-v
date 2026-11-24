import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/history/data/models/history_item.dart';
import 'package:safescan_app/features/history/providers/history_provider.dart';
import 'package:safescan_app/features/result/data/models/product.dart';

void main() {
  final items = <HistoryItem>[
    HistoryItem(id: '1', product: const Product(barcode: '1', name: 'Whole Oats', brand: 'Harvest', category: ProductCategory.food), safetyScore: 92, classification: SafetyClassification.safe, scannedAt: DateTime(2026, 11, 20, 10)),
    HistoryItem(id: '2', product: const Product(barcode: '2', name: 'Face Cream', brand: 'Gentle', category: ProductCategory.cosmetic), safetyScore: 42, classification: SafetyClassification.flagged, scannedAt: DateTime(2026, 11, 18, 10)),
    HistoryItem(id: '3', product: const Product(barcode: '3', name: 'Snack Bar', brand: 'Treats', category: ProductCategory.food), safetyScore: 55, classification: SafetyClassification.needsAttention, scannedAt: DateTime(2026, 11, 10, 10)),
  ];

  test('search combines with category and status filters', () {
    final filters = const HistoryFilters(category: HistoryCategoryFilter.food, status: HistoryStatusFilter.needsAttention);
    final result = filterHistory(items, 'snack', filters);

    expect(result, hasLength(1));
    expect(result.first.id, '3');
  });

  test('brand search and date range work', () {
    expect(filterHistory(items, 'gentle', const HistoryFilters()), hasLength(1));

    final ranged = filterHistory(items, '', HistoryFilters(startDate: DateTime(2026, 11, 11), endDate: DateTime(2026, 11, 20)));
    expect(ranged, hasLength(2));
  });

  test('category filter excludes non-matching products', () {
    final cosmetic = filterHistory(items, '', const HistoryFilters(category: HistoryCategoryFilter.cosmetic));
    expect(cosmetic, hasLength(1));
  });
}
