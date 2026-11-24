import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.message, this.icon = Icons.inbox_outlined, super.key});

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: AppSizing.iconXl, color: AppColors.secondaryText),
              const SizedBox(height: AppSpacing.md),
              Text(title, textAlign: TextAlign.center, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.sm),
              Text(message, textAlign: TextAlign.center, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
