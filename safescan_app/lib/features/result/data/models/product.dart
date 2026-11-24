enum ProductCategory { food, cosmetic }

enum NutriScore { a, b, c, d, e }

enum SafetyClassification { safe, needsAttention, flagged, unknown }

enum VerificationStatus { verified, uncertain, missing, unableToVerify }

class Product {
  const Product({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.category,
    this.imageUrl,
  });

  final String barcode;
  final String name;
  final String brand;
  final ProductCategory category;
  final String? imageUrl;

  bool get isFood => category == ProductCategory.food;
}
