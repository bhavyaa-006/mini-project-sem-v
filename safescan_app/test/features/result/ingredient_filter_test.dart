import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/result/data/models/product.dart';
import 'package:safescan_app/features/result/data/models/safety_models.dart';
import 'package:safescan_app/features/result/presentation/ingredient_filter.dart';

void main() {
  const ingredients = <Ingredient>[
    Ingredient(name: 'Whole oats', classification: SafetyClassification.safe, purpose: 'Main grain', concerns: <String>[], warnings: <String>[], verificationStatus: VerificationStatus.verified),
    Ingredient(name: 'Added sugar', classification: SafetyClassification.needsAttention, purpose: 'Sweetener', concerns: <String>['Sugar'], warnings: <String>[], verificationStatus: VerificationStatus.verified),
    Ingredient(name: 'Fragrance', classification: SafetyClassification.flagged, purpose: 'Scent', concerns: <String>['Skin sensitivity'], warnings: <String>['Patch test'], verificationStatus: VerificationStatus.uncertain),
  ];

  test('All filter returns every ingredient', () {
    expect(filterIngredients(ingredients, IngredientFilter.all, ''), hasLength(3));
  });

  test('Classification filters return matching ingredients', () {
    expect(filterIngredients(ingredients, IngredientFilter.safe, '').single.name, 'Whole oats');
    expect(filterIngredients(ingredients, IngredientFilter.needsAttention, '').single.name, 'Added sugar');
    expect(filterIngredients(ingredients, IngredientFilter.flagged, '').single.name, 'Fragrance');
  });

  test('Search matches name and purpose and has empty state support', () {
    expect(filterIngredients(ingredients, IngredientFilter.all, 'sweet'), hasLength(1));
    expect(filterIngredients(ingredients, IngredientFilter.all, 'unknown'), isEmpty);
  });
}
