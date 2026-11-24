import '../../result/data/models/product.dart';
import 'models/alternative_product.dart';

abstract interface class AlternativesRepository {
  Future<List<AlternativeProduct>> getAlternatives(String productId);
}

class MockAlternativesRepository implements AlternativesRepository {
  const MockAlternativesRepository({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;

  @override
  Future<List<AlternativeProduct>> getAlternatives(String productId) async {
    await Future<void>.delayed(delay);
    return const <AlternativeProduct>[
      AlternativeProduct(product: Product(barcode: 'MOCK-ALT-1', name: 'MOCK Lower-Sugar Oats', brand: 'Mock Harvest', category: ProductCategory.food), safetyScore: 94, reason: 'MOCK: Lower added sugar and a clear ingredient list.'),
      AlternativeProduct(product: Product(barcode: 'MOCK-ALT-2', name: 'MOCK Mild Face Cleanser', brand: 'Mock SkinCare', category: ProductCategory.cosmetic), safetyScore: 89, reason: 'MOCK: Shorter ingredient list and fragrance-free positioning.'),
      AlternativeProduct(product: Product(barcode: 'MOCK-ALT-3', name: 'MOCK Reduced-Salt Crackers', brand: 'Mock Pantry', category: ProductCategory.food), safetyScore: 91, reason: 'MOCK: Less salt and no artificial sweetener.'),
      AlternativeProduct(product: Product(barcode: 'MOCK-ALT-4', name: 'MOCK Unscented Lotion', brand: 'Mock Gentle', category: ProductCategory.cosmetic), safetyScore: 86, reason: 'MOCK: Fragrance-free and a short ingredient list.'),
      AlternativeProduct(product: Product(barcode: 'MOCK-ALT-5', name: 'MOCK High-Fibre Cereal', brand: 'Mock Grain Co.', category: ProductCategory.food), safetyScore: 84, reason: 'MOCK: Higher fibre and moderate sugar.'),
      AlternativeProduct(product: Product(barcode: 'MOCK-ALT-6', name: 'MOCK Barrier Cream', brand: 'Mock Derma', category: ProductCategory.cosmetic), safetyScore: 82, reason: 'MOCK: Simple moisturising ingredients for sensitive skin.'),
    ];
  }
}

class RealAlternativesRepository implements AlternativesRepository {
  const RealAlternativesRepository();

  @override
  Future<List<AlternativeProduct>> getAlternatives(String productId) {
    throw UnimplementedError('Real alternatives repository is not implemented.');
  }
}
