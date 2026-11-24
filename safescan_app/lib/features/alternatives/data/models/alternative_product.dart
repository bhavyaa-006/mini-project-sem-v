import '../../../result/data/models/product.dart';

class AlternativeProduct {
  const AlternativeProduct({
    required this.product,
    required this.safetyScore,
    required this.reason,
  });

  final Product product;
  final int safetyScore;
  final String reason;
}
