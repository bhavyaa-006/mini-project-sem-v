import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppScoreColors {
  static const safetyBands = <int, Color>{
    80: AppColors.scoreExcellent,
    60: AppColors.scoreGood,
    40: AppColors.scoreFair,
    20: AppColors.scorePoor,
    0: AppColors.scoreVeryPoor,
  };

  static const nutriScores = <String, Color>{
    'A': AppColors.nutriA,
    'B': AppColors.nutriB,
    'C': AppColors.nutriC,
    'D': AppColors.nutriD,
    'E': AppColors.nutriE,
  };
}
