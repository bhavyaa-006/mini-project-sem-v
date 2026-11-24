import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({this.message = 'You are offline. Some features may be unavailable.', super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.wifi_off_outlined, size: AppSizing.iconSm, color: AppColors.text),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: AppTypography.bodySmall.copyWith(color: AppColors.text))),
        ],
      ),
    );
  }
}
