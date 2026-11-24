import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/core/utils/auth_validators.dart';
import 'package:safescan_app/features/profile/data/models/user_preferences.dart';
import 'package:safescan_app/features/profile/data/profile_repository.dart';
import 'package:safescan_app/features/profile/providers/profile_provider.dart';

void main() {
  test('profile provider loads mock profile', () async {
    final container = ProviderContainer(overrides: [profileRepositoryProvider.overrideWithValue(const MockProfileRepository(delay: Duration.zero))]);
    addTearDown(container.dispose);

    final profile = await container.read(profileProvider.future);

    expect(profile.name, 'Aarav');
    expect(profile.allergies, contains('Peanuts'));
  });

  test('profile provider persists changes during session', () async {
    final container = ProviderContainer(overrides: [profileRepositoryProvider.overrideWithValue(const MockProfileRepository(delay: Duration.zero))]);
    addTearDown(container.dispose);

    await container.read(profileProvider.future);
    const changed = UserProfile(name: 'Meera', email: 'meera@example.com', allergies: <String>['Milk'], dietaryPreferences: <String>['Jain'], skinType: SkinType.dry, ingredientPreferences: <String>['Palm oil']);

    final saved = await container.read(profileProvider.notifier).save(changed);

    expect(saved, isTrue);
    expect(container.read(profileProvider).value?.name, 'Meera');
    expect(container.read(profileProvider).value?.skinType, SkinType.dry);
  });

  test('profile validation rejects blank name and invalid email', () {
    expect(AuthValidators.required('', 'Name'), isNotNull);
    expect(AuthValidators.required('Aarav', 'Name'), isNull);
    expect(AuthValidators.email('invalid'), isNotNull);
    expect(AuthValidators.email('meera@example.com'), isNull);
  });
}
