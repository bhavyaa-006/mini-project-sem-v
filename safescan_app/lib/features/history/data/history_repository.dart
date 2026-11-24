import '../../result/data/models/product.dart';
import 'models/history_item.dart';

abstract interface class HistoryRepository {
  Future<List<HistoryItem>> getHistory();
  Future<void> addHistoryItem(HistoryItem item);
  Future<void> deleteHistoryItem(String id);
  Future<void> clearHistory();
}

class MockHistoryRepository implements HistoryRepository {
  const MockHistoryRepository({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;

  static final List<HistoryItem> _items = <HistoryItem>[
    HistoryItem(id: 'mock-history-1', product: const Product(barcode: '890100100001', name: 'MOCK Wholegrain Breakfast Oats', brand: 'Mock Harvest', category: ProductCategory.food), safetyScore: 92, classification: SafetyClassification.safe, scannedAt: DateTime(2026, 11, 20, 10, 30)),
    HistoryItem(id: 'mock-history-2', product: const Product(barcode: '890100100004', name: 'MOCK Strong Perfume Cream', brand: 'Mock Beauty', category: ProductCategory.cosmetic), safetyScore: 42, classification: SafetyClassification.flagged, scannedAt: DateTime(2026, 11, 19, 18, 10)),
    HistoryItem(id: 'mock-history-3', product: const Product(barcode: '890100100003', name: 'MOCK Gentle Face Moisturiser', brand: 'Mock SkinCare', category: ProductCategory.cosmetic), safetyScore: 88, classification: SafetyClassification.safe, scannedAt: DateTime(2026, 11, 18, 9, 15)),
  ];

  @override
  Future<List<HistoryItem>> getHistory() async {
    await Future<void>.delayed(delay);
    return List<HistoryItem>.unmodifiable(_items);
  }

  @override
  Future<void> addHistoryItem(HistoryItem item) async {
    await Future<void>.delayed(delay);
    _items.insert(0, item);
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    await Future<void>.delayed(delay);
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> clearHistory() async {
    await Future<void>.delayed(delay);
    _items.clear();
  }
}

class RealHistoryRepository implements HistoryRepository {
  const RealHistoryRepository();

  @override
  Future<List<HistoryItem>> getHistory() {
    throw UnimplementedError('Real history repository is not implemented.');
  }

  @override
  Future<void> addHistoryItem(HistoryItem item) {
    throw UnimplementedError('Real history repository is not implemented.');
  }

  @override
  Future<void> deleteHistoryItem(String id) {
    throw UnimplementedError('Real history repository is not implemented.');
  }

  @override
  Future<void> clearHistory() {
    throw UnimplementedError('Real history repository is not implemented.');
  }
}
