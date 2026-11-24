import 'product.dart';
import 'safety_models.dart';
import 'scan_result.dart';

Map<String, ScanResult> buildMockScanResults() {
  const timestamp = '2026-11-20T10:30:00Z';

  ScanResult scan({
    required String id,
    required String barcode,
    required String name,
    required String brand,
    required ProductCategory category,
    required int score,
    required SafetyClassification classification,
    required NutriScore? nutri,
    required CosmeticSafetyScore? cosmetic,
    required LegalMetrologyInfo legal,
    required String why,
  }) {
    return ScanResult(
      id: id,
      product: Product(barcode: barcode, name: name, brand: brand, category: category),
      timestamp: DateTime.parse(timestamp),
      overallSafetyScore: score,
      safetyClassification: classification,
      nutriScore: nutri,
      cosmeticSafetyScore: cosmetic,
      ingredients: category == ProductCategory.food
          ? <Ingredient>[
              Ingredient(name: 'MOCK Whole oats', classification: SafetyClassification.safe, purpose: 'Main ingredient', concerns: <String>[], warnings: <String>[], verificationStatus: VerificationStatus.verified),
              Ingredient(name: 'MOCK Added sugar', classification: score >= 60 ? SafetyClassification.needsAttention : SafetyClassification.flagged, purpose: 'Sweetener', concerns: <String>['MOCK: Added sugar'], warnings: <String>['Check personal dietary limits'], verificationStatus: VerificationStatus.verified),
              Ingredient(name: 'MOCK Preservative', classification: SafetyClassification.needsAttention, purpose: 'Shelf-life support', concerns: <String>['MOCK: Sensitivity possible'], warnings: <String>['Sensitive users may react'], verificationStatus: VerificationStatus.uncertain),
            ]
          : <Ingredient>[
              Ingredient(name: 'MOCK Glycerin', classification: SafetyClassification.safe, purpose: 'Humectant', concerns: <String>[], warnings: <String>[], verificationStatus: VerificationStatus.verified),
              Ingredient(name: 'MOCK Fragrance', classification: score < 60 ? SafetyClassification.flagged : SafetyClassification.needsAttention, purpose: 'Scent', concerns: <String>['MOCK: Skin sensitivity'], warnings: <String>['Patch test for sensitive skin'], verificationStatus: VerificationStatus.verified),
              Ingredient(name: 'MOCK Preservative', classification: SafetyClassification.needsAttention, purpose: 'Shelf-life support', concerns: <String>['MOCK: Source uncertain'], warnings: <String>[], verificationStatus: VerificationStatus.uncertain),
            ],
      legalMetrology: legal,
      explanation: ScoreExplanation(why: 'MOCK: $why', verifiedItems: const <String>['MOCK: Clearly printed package text'], uncertainItems: const <String>['MOCK: Ingredient source could not be independently confirmed']),
    );
  }

  LegalMetrologyInfo legal({required String status, String? mrp, String? quantity, String? manufacturer}) {
    final fieldStatus = <String, LegalFieldStatus>{
      'MRP': status == 'compliant' ? LegalFieldStatus.compliant : status == 'missing' ? LegalFieldStatus.missing : status == 'non-compliant' ? LegalFieldStatus.nonCompliant : LegalFieldStatus.unableToVerify,
      'Net quantity': status == 'compliant' ? LegalFieldStatus.compliant : status == 'missing' ? LegalFieldStatus.missing : status == 'non-compliant' ? LegalFieldStatus.nonCompliant : LegalFieldStatus.unableToVerify,
      'Manufacturer': status == 'compliant' ? LegalFieldStatus.compliant : status == 'missing' ? LegalFieldStatus.missing : status == 'non-compliant' ? LegalFieldStatus.nonCompliant : LegalFieldStatus.unableToVerify,
      'Expiry date': status == 'compliant' ? LegalFieldStatus.compliant : status == 'missing' ? LegalFieldStatus.missing : status == 'non-compliant' ? LegalFieldStatus.nonCompliant : LegalFieldStatus.unableToVerify,
    };
    return LegalMetrologyInfo(mrp: mrp, netQuantity: quantity, manufacturer: manufacturer, expiryDate: status == 'missing' ? null : '2027-06', mandatoryDeclarations: const <String>['MRP', 'Net quantity', 'Manufacturer', 'Expiry date'], fieldStatuses: fieldStatus);
  }

  return <String, ScanResult>{
    '890100100001': scan(id: 'mock-food-good', barcode: '890100100001', name: 'MOCK Wholegrain Breakfast Oats', brand: 'Mock Harvest', category: ProductCategory.food, score: 92, classification: SafetyClassification.safe, nutri: NutriScore.a, cosmetic: null, legal: legal(status: 'compliant', mrp: '₹180', quantity: '500 g', manufacturer: 'Mock Harvest Foods'), why: 'Wholegrain oats with low added sugar and complete label details.'),
    '890100100002': scan(id: 'mock-food-poor', barcode: '890100100002', name: 'MOCK Sugary Snack Bar', brand: 'Mock Treats', category: ProductCategory.food, score: 38, classification: SafetyClassification.flagged, nutri: NutriScore.e, cosmetic: null, legal: legal(status: 'compliant', mrp: '₹45', quantity: '40 g', manufacturer: 'Mock Treats India'), why: 'High sugar and fat content with low nutritional balance.'),
    '890100100003': scan(id: 'mock-cosmetic-good', barcode: '890100100003', name: 'MOCK Gentle Face Moisturiser', brand: 'Mock SkinCare', category: ProductCategory.cosmetic, score: 88, classification: SafetyClassification.safe, nutri: null, cosmetic: const CosmeticSafetyScore(88), legal: legal(status: 'compliant', mrp: '₹320', quantity: '50 ml', manufacturer: 'Mock SkinCare Labs'), why: 'Short ingredient list with no commonly concerning allergens in this mock result.'),
    '890100100004': scan(id: 'mock-cosmetic-flagged', barcode: '890100100004', name: 'MOCK Strong Perfume Cream', brand: 'Mock Beauty', category: ProductCategory.cosmetic, score: 42, classification: SafetyClassification.flagged, nutri: null, cosmetic: const CosmeticSafetyScore(42), legal: legal(status: 'compliant', mrp: '₹450', quantity: '100 ml', manufacturer: 'Mock Beauty Labs'), why: 'Contains mock fragrance and preservative concerns for sensitive skin.'),
    '890100100005': scan(id: 'mock-missing-legal', barcode: '890100100005', name: 'MOCK Imported Cereal Pack', brand: 'Mock Global', category: ProductCategory.food, score: 61, classification: SafetyClassification.needsAttention, nutri: NutriScore.c, cosmetic: null, legal: legal(status: 'missing', mrp: null, quantity: null, manufacturer: null), why: 'The sample label is missing several mandatory legal declarations.'),
    '890100100006': scan(id: 'mock-noncompliant', barcode: '890100100006', name: 'MOCK Loose Label Beverage', brand: 'Mock Drinks', category: ProductCategory.food, score: 24, classification: SafetyClassification.flagged, nutri: NutriScore.e, cosmetic: null, legal: legal(status: 'non-compliant', mrp: '999', quantity: '—', manufacturer: 'Not clearly shown'), why: 'Mock legal text appears incomplete or inconsistently formatted.'),
    '890100100007': scan(id: 'mock-cosmetic-unknown', barcode: '890100100007', name: 'MOCK Limited Ingredient Balm', brand: 'Mock Minimal', category: ProductCategory.cosmetic, score: 55, classification: SafetyClassification.needsAttention, nutri: null, cosmetic: const CosmeticSafetyScore(55), legal: legal(status: 'unable-to-verify', mrp: null, quantity: '30 g', manufacturer: null), why: 'This mock label could not be fully verified.'),
  };
}
