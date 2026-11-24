import 'models/user_preferences.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> saveProfile(UserProfile profile);
}

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository({this.delay = const Duration(milliseconds: 400)});

  final Duration delay;

  static UserProfile _mockProfile = const UserProfile(
    name: 'Aarav',
    email: 'aarav@example.com',
    allergies: <String>['Peanuts'],
    dietaryPreferences: <String>['Vegetarian'],
    skinType: SkinType.sensitive,
    ingredientPreferences: <String>['Fragrance'],
  );

  @override
  Future<UserProfile> getProfile() async {
    await Future<void>.delayed(delay);
    return _mockProfile;
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) async {
    await Future<void>.delayed(delay);
    _mockProfile = profile;
    return profile;
  }
}

class RealProfileRepository implements ProfileRepository {
  const RealProfileRepository();

  @override
  Future<UserProfile> getProfile() {
    throw UnimplementedError('Real profile repository is not implemented.');
  }

  @override
  Future<UserProfile> saveProfile(UserProfile profile) {
    throw UnimplementedError('Real profile repository is not implemented.');
  }
}
