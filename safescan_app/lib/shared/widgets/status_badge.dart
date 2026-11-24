import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum AppStatus { safe, needsAttention, flagged, compliant, nonCompliant, informationMissing, unableToVerify }

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final AppStatus status;

  static const Map<AppStatus, String> _labels = <AppStatus, String>{
    AppStatus.safe: 'Safe',
    AppStatus.needsAttention: 'Needs attention',
    AppStatus.flagged: 'Flagged',
    AppStatus.compliant: 'Compliant',
    AppStatus.nonCompliant: 'Non-compliant',
    AppStatus.informationMissing: 'Information missing',
    AppStatus.unableToVerify: 'Unable to verify',
  };

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    switch (status) {
      case AppStatus.safe:
      case AppStatus.compliant:
        icon = Icons.check_circle_outline;
        color = AppColors.success;
      case AppStatus.needsAttention:
        icon = Icons.warning_amber_rounded;
        color = AppColors.warning;
      case AppStatus.flagged:
      case AppStatus.nonCompliant:
        icon = Icons.cancel_outlined;
        color = AppColors.danger;
      case AppStatus.informationMissing:
      case AppStatus.unableToVerify:
        icon = Icons.help_outline;
        color = AppColors.secondaryText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppSizing.iconSm, color: color),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              _labels[status]!,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
