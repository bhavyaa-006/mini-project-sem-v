import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/repository_config.dart';
import '../data/models/user_preferences.dart';
import '../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final mode = ref.watch(repositoryModeProvider);
  return mode == RepositoryMode.mock
      ? const MockProfileRepository()
      : const RealProfileRepository();
});

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    return ref.watch(profileRepositoryProvider).getProfile();
  }

  Future<bool> save(UserProfile profile) async {
    state = const AsyncLoading<UserProfile>();
    try {
      final saved = await ref.read(profileRepositoryProvider).saveProfile(profile);
      state = AsyncData<UserProfile>(saved);
      return true;
    } catch (_) {
      state = AsyncError<UserProfile>('Profile could not be saved. Please try again.', StackTrace.current);
      return false;
    }
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);
