enum SkinType { normal, dry, oily, combination, sensitive, unknown }

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.allergies,
    required this.dietaryPreferences,
    required this.skinType,
    required this.ingredientPreferences,
  });

  final String name;
  final String email;
  final List<String> allergies;
  final List<String> dietaryPreferences;
  final SkinType skinType;
  final List<String> ingredientPreferences;

  UserProfile copyWith({
    String? name,
    String? email,
    List<String>? allergies,
    List<String>? dietaryPreferences,
    SkinType? skinType,
    List<String>? ingredientPreferences,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      allergies: allergies ?? this.allergies,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      skinType: skinType ?? this.skinType,
      ingredientPreferences: ingredientPreferences ?? this.ingredientPreferences,
    );
  }
}
