import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AppStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureAppStorage implements AppStorage {
  SecureAppStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class MockAppStorage implements AppStorage {
  MockAppStorage({bool onboardingSeen = false, bool signedIn = false})
      : _values = <String, String>{
          AppStorageKeys.onboardingSeen: onboardingSeen ? 'true' : 'false',
          AppStorageKeys.mockSignedIn: signedIn ? 'true' : 'false',
        };

  final Map<String, String> _values;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

abstract final class AppStorageKeys {
  static const onboardingSeen = 'onboarding_seen';
  static const mockSignedIn = 'mock_signed_in';
  static const mockAuthToken = 'mock_auth_token';
}

final appStorageProvider = Provider<AppStorage>((ref) => SecureAppStorage());
