import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/routes.dart';
import '../storage/secure_storage.dart';

enum AppStartDestination { onboarding, login, home }

abstract interface class AppStartService {
  Future<AppStartDestination> getDestination();
  Future<void> completeOnboarding();
  Future<void> setMockSignedIn(bool value);
}

class StorageAppStartService implements AppStartService {
  const StorageAppStartService(this.storage);

  final AppStorage storage;

  @override
  Future<AppStartDestination> getDestination() async {
    final onboardingSeen = await storage.read(AppStorageKeys.onboardingSeen);
    if (onboardingSeen != 'true') return AppStartDestination.onboarding;

    final signedIn = await storage.read(AppStorageKeys.mockSignedIn);
    return signedIn == 'true' ? AppStartDestination.home : AppStartDestination.login;
  }

  @override
  Future<void> completeOnboarding() => storage.write(AppStorageKeys.onboardingSeen, 'true');

  @override
  Future<void> setMockSignedIn(bool value) => storage.write(AppStorageKeys.mockSignedIn, value.toString());

  static String routeFor(AppStartDestination destination) {
    switch (destination) {
      case AppStartDestination.onboarding:
        return AppRoutes.onboarding;
      case AppStartDestination.login:
        return AppRoutes.login;
      case AppStartDestination.home:
        return AppRoutes.home;
    }
  }
}

final appStartServiceProvider = Provider<AppStartService>((ref) {
  return StorageAppStartService(ref.watch(appStorageProvider));
});

final appStartDestinationProvider = FutureProvider<AppStartDestination>((ref) {
  return ref.watch(appStartServiceProvider).getDestination();
});
