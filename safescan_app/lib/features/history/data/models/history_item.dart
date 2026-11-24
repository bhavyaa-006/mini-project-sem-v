import '../../../result/data/models/product.dart';

class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.product,
    required this.safetyScore,
    required this.classification,
    required this.scannedAt,
  });

  final String id;
  final Product product;
  final int safetyScore;
  final SafetyClassification classification;
  final DateTime scannedAt;
}
