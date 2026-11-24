import '../data/models/product.dart';
import '../data/models/safety_models.dart';

enum IngredientFilter { all, safe, needsAttention, flagged }

List<Ingredient> filterIngredients(List<Ingredient> ingredients, IngredientFilter filter, String query) {
  final normalized = query.trim().toLowerCase();

  return ingredients.where((ingredient) {
    final matchesFilter = switch (filter) {
      IngredientFilter.all => true,
      IngredientFilter.safe => ingredient.classification == SafetyClassification.safe,
      IngredientFilter.needsAttention => ingredient.classification == SafetyClassification.needsAttention,
      IngredientFilter.flagged => ingredient.classification == SafetyClassification.flagged,
    };

    final matchesSearch = normalized.isEmpty ||
        ingredient.name.toLowerCase().contains(normalized) ||
        ingredient.purpose.toLowerCase().contains(normalized);

    return matchesFilter && matchesSearch;
  }).toList();
}
