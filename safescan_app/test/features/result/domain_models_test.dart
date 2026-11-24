import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/result/data/models/product.dart';
import 'package:safescan_app/features/result/data/models/safety_models.dart';
import 'package:safescan_app/features/result/data/models/scan_result.dart';

void main() {
  test('cosmetic score returns the correct classification bands', () {
    expect(const CosmeticSafetyScore(88).classification, SafetyClassification.safe);
    expect(const CosmeticSafetyScore(65).classification, SafetyClassification.needsAttention);
    expect(const CosmeticSafetyScore(42).classification, SafetyClassification.flagged);
  });

  test('scan result score band is derived from score', () {
    final product = const Product(barcode: '1', name: 'Test', brand: 'Mock', category: ProductCategory.food);
    final legal = LegalMetrologyInfo(mrp: '₹10', netQuantity: '100 g', manufacturer: 'Mock', expiryDate: '2027', mandatoryDeclarations: const <String>['MRP'], fieldStatuses: const <String, LegalFieldStatus>{'MRP': LegalFieldStatus.compliant});

    final result = ScanResult(id: 'test', product: product, timestamp: DateTime(2026), overallSafetyScore: 84, safetyClassification: SafetyClassification.safe, legalMetrology: legal, explanation: const ScoreExplanation(why: 'Mock', verifiedItems: <String>[], uncertainItems: <String>[]));

    expect(result.scoreBand, SafetyClassification.safe);
  });

  test('legal information is compliant only when every field is compliant', () {
    const legal = LegalMetrologyInfo(mrp: '₹10', netQuantity: '100 g', manufacturer: 'Mock', expiryDate: '2027', mandatoryDeclarations: <String>['MRP'], fieldStatuses: <String, LegalFieldStatus>{'MRP': LegalFieldStatus.compliant, 'Net quantity': LegalFieldStatus.missing});

    expect(legal.isCompliant, isFalse);
  });
}
