import 'product.dart';
import 'safety_models.dart';

class ScanResult {
  const ScanResult({
    required this.id,
    required this.product,
    required this.timestamp,
    required this.overallSafetyScore,
    required this.safetyClassification,
    this.nutriScore,
    this.cosmeticSafetyScore,
    this.ingredients = const <Ingredient>[],
    required this.legalMetrology,
    required this.explanation,
  }) : assert(overallSafetyScore >= 0 && overallSafetyScore <= 100);

  final String id;
  final Product product;
  final DateTime timestamp;
  final int overallSafetyScore;
  final SafetyClassification safetyClassification;
  final NutriScore? nutriScore;
  final CosmeticSafetyScore? cosmeticSafetyScore;
  final List<Ingredient> ingredients;
  final LegalMetrologyInfo legalMetrology;
  final ScoreExplanation explanation;

  SafetyClassification get scoreBand {
    if (overallSafetyScore >= 80) return SafetyClassification.safe;
    if (overallSafetyScore >= 60) return SafetyClassification.needsAttention;
    if (overallSafetyScore > 0) return SafetyClassification.flagged;
    return SafetyClassification.unknown;
  }
}
