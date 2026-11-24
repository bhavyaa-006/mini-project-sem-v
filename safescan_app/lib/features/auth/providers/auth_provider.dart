import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../data/auth_repository.dart';
import '../data/models/user.dart';

enum AuthStatus { signedOut, loading, signedIn, error }

class AuthState {
  const AuthState({required this.status, this.user, this.message});

  const AuthState.signedOut() : this(status: AuthStatus.signedOut);
  const AuthState.loading() : this(status: AuthStatus.loading);
  const AuthState.signedIn(AuthUser user) : this(status: AuthStatus.signedIn, user: user);
  const AuthState.error(String message) : this(status: AuthStatus.error, message: message);

  final AuthStatus status;
  final AuthUser? user;
  final String? message;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => const MockAuthRepository());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    unawaited(_restoreSession());
    return const AuthState.loading();
  }

  AppStorage get _storage => ref.read(appStorageProvider);
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> _restoreSession() async {
    final token = await _storage.read(AppStorageKeys.mockAuthToken);
    if (token == null || token.isEmpty) {
      state = const AuthState.signedOut();
      return;
    }

    state = const AuthState.signedIn(AuthUser(id: 'mock-user-1', name: 'Aarav', email: 'aarav@example.com'));
  }

  Future<void> login(AuthCredentials credentials) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(credentials);
      await _storage.write(AppStorageKeys.mockAuthToken, 'MOCK_FAKE_TOKEN_not_real');
      await _storage.write(AppStorageKeys.mockSignedIn, 'true');
      state = AuthState.signedIn(user);
    } on MockAuthException catch (error) {
      state = AuthState.error(error.message);
    } catch (_) {
      state = const AuthState.error('Something went wrong. Please try again.');
    }
  }

  Future<void> register(RegistrationData data) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.register(data);
      await _storage.write(AppStorageKeys.mockAuthToken, 'MOCK_FAKE_TOKEN_not_real');
      await _storage.write(AppStorageKeys.mockSignedIn, 'true');
      state = AuthState.signedIn(user);
    } on MockAuthException catch (error) {
      state = AuthState.error(error.message);
    } catch (_) {
      state = const AuthState.error('Something went wrong. Please try again.');
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    await _repository.logout();
    await _storage.delete(AppStorageKeys.mockAuthToken);
    await _storage.write(AppStorageKeys.mockSignedIn, 'false');
    state = const AuthState.signedOut();
  }
}
