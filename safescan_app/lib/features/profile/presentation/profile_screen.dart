import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log out?'),
            content: const Text(
              'You will need to sign in again to access profile and saved features.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Log out'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit profile',
            onPressed: () => context.push(AppRoutes.editProfile),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: profile.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: <Widget>[
                SkeletonLoader(width: 80, height: 80),
                SizedBox(height: AppSpacing.md),
                SkeletonLoader(width: 220, height: 24),
                SizedBox(height: AppSpacing.lg),
                SkeletonLoader(width: double.infinity, height: 180),
              ],
            ),
          ),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(profileProvider),
          ),
          data: (data) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppCard(
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 38,
                            backgroundColor: AppColors.mint,
                            foregroundColor: AppColors.primary,
                            child: Text(
                              data.name.isEmpty
                                  ? '?'
                                  : data.name[0].toUpperCase(),
                              style: AppTypography.headline,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(data.name, style: AppTypography.headline),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  data.email,
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Preferences', style: AppTypography.title),
                          const SizedBox(height: AppSpacing.md),
                          _PreferenceRow(
                            label: 'Allergies',
                            value: data.allergies.isEmpty
                                ? 'None selected'
                                : data.allergies.join(', '),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _PreferenceRow(
                            label: 'Diet',
                            value: data.dietaryPreferences.isEmpty
                                ? 'None selected'
                                : data.dietaryPreferences.join(', '),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _PreferenceRow(
                            label: 'Skin type',
                            value:
                                data.skinType.name[0].toUpperCase() +
                                data.skinType.name.substring(1),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _PreferenceRow(
                            label: 'Avoid ingredients',
                            value: data.ingredientPreferences.isEmpty
                                ? 'None selected'
                                : data.ingredientPreferences.join(', '),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('App info', style: AppTypography.title),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'SafeScan & PackCheck AI',
                            style: AppTypography.body,
                          ),
                          Text('Version 1.0.0', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.editProfile),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit profile'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                        ),
                        onPressed: () => _logout(context, ref),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 118, child: Text(label, style: AppTypography.label)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(value, style: AppTypography.bodySmall)),
      ],
    );
  }
}
