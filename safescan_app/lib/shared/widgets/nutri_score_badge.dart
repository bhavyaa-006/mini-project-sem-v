import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_score_colors.dart';
import '../../core/theme/app_sizing.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class NutriScoreBadge extends StatelessWidget {
  const NutriScoreBadge({required this.grade, super.key});

  final String grade;

  @override
  Widget build(BuildContext context) {
    final normalized = grade.toUpperCase();
    final color = AppScoreColors.nutriScores[normalized] ?? AppColors.secondaryText;

    return Container(
      width: AppSizing.fieldHeight,
      height: AppSizing.fieldHeight,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.md)),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Text(normalized, style: AppTypography.headline.copyWith(color: AppColors.white)),
      ),
    );
  }
}
