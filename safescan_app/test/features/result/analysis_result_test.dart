import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/result/data/analysis_repository.dart';

void main() {
  group('MockAnalysisRepository', () {
    test('returns the matching result by identifier', () async {
      final result = await const MockAnalysisRepository(delay: Duration.zero)
          .getResult('mock-food-good');

      expect(result, isNotNull);
      expect(result!.id, 'mock-food-good');
      expect(result.product.category.name, 'food');
    });

    test('returns null for an unknown identifier', () async {
      final result = await const MockAnalysisRepository(delay: Duration.zero)
          .getResult('not-a-result');

      expect(result, isNull);
    });
  });
}
