import 'models/user.dart';

class AuthCredentials {
  const AuthCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

class RegistrationData {
  const RegistrationData({required this.name, required this.email, required this.password});

  final String name;
  final String email;
  final String password;
}

abstract interface class AuthRepository {
  Future<AuthUser> login(AuthCredentials credentials);
  Future<AuthUser> register(RegistrationData data);
  Future<void> forgotPassword(String email);
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository({this.simulateNetworkError = false});

  final bool simulateNetworkError;

  @override
  Future<AuthUser> login(AuthCredentials credentials) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (simulateNetworkError) {
      throw const MockAuthException('Could not reach the service. Check your connection and try again.');
    }
    if (credentials.email.toLowerCase().trim() == 'wrong@example.com' || credentials.password == 'wrongpass') {
      throw const MockAuthException('Email or password is incorrect.');
    }

    return AuthUser(id: 'mock-user-1', name: 'Aarav', email: credentials.email.trim());
  }

  @override
  Future<AuthUser> register(RegistrationData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (simulateNetworkError) {
      throw const MockAuthException('Could not reach the service. Check your connection and try again.');
    }

    return AuthUser(id: 'mock-user-1', name: data.name.trim(), email: data.email.trim());
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<void> logout() async {}
}

class MockAuthException implements Exception {
  const MockAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
