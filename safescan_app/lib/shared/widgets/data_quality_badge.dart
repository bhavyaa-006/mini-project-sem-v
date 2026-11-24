import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class DataQualityBadge extends StatelessWidget {
  const DataQualityBadge({
    required this.label,
    this.isVerified = false,
    super.key,
  });

  final String label;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? AppColors.success : AppColors.secondaryText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          isVerified ? Icons.verified_outlined : Icons.info_outline,
          size: AppSizing.iconSm,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.label.copyWith(color: color)),
      ],
    );
  }
}
