import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/core/storage/secure_storage.dart';
import 'package:safescan_app/core/utils/auth_validators.dart';
import 'package:safescan_app/features/auth/data/auth_repository.dart';
import 'package:safescan_app/features/auth/providers/auth_provider.dart';

void main() {
  group('AuthValidators', () {
    test('validates required email and password', () {
      expect(AuthValidators.email('bad'), isNotNull);
      expect(AuthValidators.email('user@example.com'), isNull);
      expect(AuthValidators.password('short'), isNotNull);
      expect(AuthValidators.password('Long1234'), isNull);
      expect(AuthValidators.confirmPassword('different', 'Long1234'), isNotNull);
      expect(AuthValidators.confirmPassword('Long1234', 'Long1234'), isNull);
    });

    test('provides password strength hints', () {
      expect(AuthValidators.passwordHint('abc'), 'Weak password');
      expect(AuthValidators.passwordHint('Longpass1'), 'Good password');
      expect(AuthValidators.passwordHint('Longpass1!'), 'Strong password');
    });
  });

  test('mock auth provider signs in, persists fake token, and logs out', () async {
    final storage = MockAppStorage(onboardingSeen: true, signedIn: false);
    final container = ProviderContainer(overrides: [
      appStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(const MockAuthRepository()),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(authProvider.notifier);
    await notifier.login(const AuthCredentials(email: 'user@example.com', password: 'Longpass1'));

    expect(container.read(authProvider).status, AuthStatus.signedIn);
    expect(await storage.read(AppStorageKeys.mockAuthToken), 'MOCK_FAKE_TOKEN_not_real');

    await notifier.logout();

    expect(container.read(authProvider).status, AuthStatus.signedOut);
    expect(await storage.read(AppStorageKeys.mockAuthToken), isNull);
  });

  test('wrong mock credentials produce a friendly error', () async {
    final storage = MockAppStorage(onboardingSeen: true, signedIn: false);
    final container = ProviderContainer(overrides: [
      appStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(const MockAuthRepository()),
    ]);
    addTearDown(container.dispose);

    final notifier = container.read(authProvider.notifier);
    await notifier.login(const AuthCredentials(email: 'wrong@example.com', password: 'Longpass1'));

    expect(container.read(authProvider).status, AuthStatus.error);
    expect(container.read(authProvider).message, 'Email or password is incorrect.');
  });
}
