import 'product.dart';

class CosmeticSafetyScore {
  const CosmeticSafetyScore(this.value)
      : assert(value >= 0 && value <= 100);

  final int value;

  SafetyClassification get classification {
    if (value >= 80) return SafetyClassification.safe;
    if (value >= 60) return SafetyClassification.needsAttention;
    if (value >= 1) return SafetyClassification.flagged;
    return SafetyClassification.unknown;
  }
}

class Ingredient {
  const Ingredient({
    required this.name,
    required this.classification,
    required this.purpose,
    required this.concerns,
    required this.warnings,
    required this.verificationStatus,
  });

  final String name;
  final SafetyClassification classification;
  final String purpose;
  final List<String> concerns;
  final List<String> warnings;
  final VerificationStatus verificationStatus;
}

enum LegalFieldStatus { compliant, nonCompliant, missing, unableToVerify }

class LegalMetrologyInfo {
  const LegalMetrologyInfo({
    required this.mrp,
    required this.netQuantity,
    required this.manufacturer,
    required this.expiryDate,
    required this.mandatoryDeclarations,
    required this.fieldStatuses,
  });

  final String? mrp;
  final String? netQuantity;
  final String? manufacturer;
  final String? expiryDate;
  final List<String> mandatoryDeclarations;
  final Map<String, LegalFieldStatus> fieldStatuses;

  bool get isCompliant =>
      fieldStatuses.isNotEmpty &&
      fieldStatuses.values.every((status) => status == LegalFieldStatus.compliant);
}

class ScoreExplanation {
  const ScoreExplanation({
    required this.why,
    required this.verifiedItems,
    required this.uncertainItems,
  });

  final String why;
  final List<String> verifiedItems;
  final List<String> uncertainItems;
}
