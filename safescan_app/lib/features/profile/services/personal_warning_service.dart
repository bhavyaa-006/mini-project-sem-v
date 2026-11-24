import '../../result/data/models/safety_models.dart';
import '../data/models/user_preferences.dart';

enum PersonalWarningType { allergy, skin, avoidedIngredient }

class PersonalWarning {
  const PersonalWarning({required this.type, required this.title, required this.message, this.ingredientName});

  final PersonalWarningType type;
  final String title;
  final String message;
  final String? ingredientName;
}

class PersonalWarningService {
  const PersonalWarningService();

  bool isProfileComplete(UserProfile profile) {
    return profile.allergies.isNotEmpty ||
        profile.dietaryPreferences.isNotEmpty ||
        profile.skinType != SkinType.unknown ||
        profile.ingredientPreferences.isNotEmpty;
  }

  List<PersonalWarning> findWarnings(UserProfile profile, List<Ingredient> ingredients) {
    final warnings = <PersonalWarning>[];

    for (final allergy in profile.allergies) {
      if (allergy == 'No known allergies') continue;
      final normalized = allergy.toLowerCase();
      for (final ingredient in ingredients) {
        final text = _ingredientText(ingredient).toLowerCase();
        if (text.contains(normalized) || _allergyAlias(normalized, ingredient)) {
          warnings.add(PersonalWarning(type: PersonalWarningType.allergy, title: 'Allergy warning', message: 'This mock ingredient list may relate to your $allergy preference.', ingredientName: ingredient.name));
        }
      }
    }

    if (profile.skinType == SkinType.sensitive) {
      for (final ingredient in ingredients) {
        final text = _ingredientText(ingredient).toLowerCase();
        if (text.contains('fragrance') || text.contains('preservative') || text.contains('sensitivity') || text.contains('skin')) {
          warnings.add(PersonalWarning(type: PersonalWarningType.skin, title: 'Sensitive skin warning', message: '${ingredient.name} may need a patch test for sensitive skin.', ingredientName: ingredient.name));
        }
      }
    }

    for (final avoid in profile.ingredientPreferences) {
      final normalized = avoid.toLowerCase();
      for (final ingredient in ingredients) {
        if (_ingredientText(ingredient).toLowerCase().contains(normalized)) {
          warnings.add(PersonalWarning(type: PersonalWarningType.avoidedIngredient, title: 'Ingredient you avoid', message: 'You selected “$avoid” as an ingredient to avoid.', ingredientName: ingredient.name));
        }
      }
    }

    final unique = <String, PersonalWarning>{};
    for (final warning in warnings) {
      unique['${warning.type.name}-${warning.ingredientName}-${warning.title}'] = warning;
    }
    return unique.values.toList();
  }

  String _ingredientText(Ingredient ingredient) {
    return '${ingredient.name} ${ingredient.purpose} ${ingredient.concerns.join(' ')} ${ingredient.warnings.join(' ')}';
  }

  bool _allergyAlias(String allergy, Ingredient ingredient) {
    final text = _ingredientText(ingredient).toLowerCase();
    if (allergy.contains('milk') && (text.contains('glycerin') || text.contains('lactose'))) return true;
    if ((allergy.contains('wheat') || allergy.contains('gluten')) && text.contains('wheat')) return true;
    if (allergy.contains('peanut') && text.contains('peanut')) return true;
    if (allergy.contains('soy') && text.contains('soy')) return true;
    return false;
  }
}
