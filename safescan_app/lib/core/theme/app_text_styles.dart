import 'package:material_ui/material_ui.dart';

import 'app_typography.dart';

abstract final class AppTextStyles {
  static TextStyle get display => AppTypography.display;
  static TextStyle get headline => AppTypography.headline;
  static TextStyle get title => AppTypography.title;
  static TextStyle get heading => AppTypography.title;
  static TextStyle get body => AppTypography.body;
  static TextStyle get secondary => AppTypography.bodySmall;
  static TextStyle get label => AppTypography.label;
}
