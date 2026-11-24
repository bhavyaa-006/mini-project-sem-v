import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/profile/data/models/user_preferences.dart';
import 'package:safescan_app/features/profile/services/personal_warning_service.dart';
import 'package:safescan_app/features/result/data/models/product.dart';
import 'package:safescan_app/features/result/data/models/safety_models.dart';

void main() {
  const service = PersonalWarningService();

  final ingredients = <Ingredient>[
    const Ingredient(name: 'MOCK Peanut oil', classification: SafetyClassification.flagged, purpose: 'Oil', concerns: <String>['Peanut'], warnings: <String>[], verificationStatus: VerificationStatus.verified),
    const Ingredient(name: 'MOCK Fragrance', classification: SafetyClassification.needsAttention, purpose: 'Scent', concerns: <String>['Skin sensitivity'], warnings: <String>['Patch test'], verificationStatus: VerificationStatus.uncertain),
  ];

  test('matches avoided ingredients and skin sensitivity', () {
    const profile = UserProfile(name: 'Aarav', email: 'a@example.com', allergies: <String>[], dietaryPreferences: <String>[], skinType: SkinType.sensitive, ingredientPreferences: <String>['Fragrance']);

    final warnings = service.findWarnings(profile, ingredients);

    expect(warnings.where((warning) => warning.type == PersonalWarningType.skin), isNotEmpty);
    expect(warnings.where((warning) => warning.type == PersonalWarningType.avoidedIngredient), isNotEmpty);
  });

  test('matches allergy preferences to ingredient text', () {
    const profile = UserProfile(name: 'Aarav', email: 'a@example.com', allergies: <String>['Peanuts'], dietaryPreferences: <String>[], skinType: SkinType.normal, ingredientPreferences: <String>[]);

    final warnings = service.findWarnings(profile, ingredients);

    expect(warnings.where((warning) => warning.type == PersonalWarningType.allergy), isNotEmpty);
  });

  test('empty profile has no personal warnings and is incomplete', () {
    const profile = UserProfile(name: '', email: '', allergies: <String>[], dietaryPreferences: <String>[], skinType: SkinType.unknown, ingredientPreferences: <String>[]);

    expect(service.isProfileComplete(profile), isFalse);
    expect(service.findWarnings(profile, ingredients), isEmpty);
  });
}
