import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 34,
        height: 1.18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.text,
      );

  static TextStyle get headline => GoogleFonts.inter(
        fontSize: 24,
        height: 1.24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.text,
      );

  static TextStyle get title => GoogleFonts.inter(
        fontSize: 20,
        height: 1.28,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        height: 1.42,
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryText,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 13,
        height: 1.34,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.text,
      );
}
