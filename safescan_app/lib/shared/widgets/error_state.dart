import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'primary_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

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
              const Icon(Icons.error_outline, size: AppSizing.iconXl, color: AppColors.danger),
              const SizedBox(height: AppSpacing.md),
              Text(message, textAlign: TextAlign.center, style: AppTypography.headline),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: 'Try again', onPressed: onRetry, icon: Icons.refresh),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
