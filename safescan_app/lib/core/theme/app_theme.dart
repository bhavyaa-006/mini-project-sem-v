import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.background,
      primary: AppColors.primary,
      secondary: AppColors.success,
      error: AppColors.danger,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.display,
      headlineMedium: AppTypography.headline,
      titleLarge: AppTypography.title,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.bodySmall,
      labelLarge: AppTypography.label,
      labelMedium: AppTypography.label,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.title,
        shape: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.secondaryText.withValues(alpha: 0.24),
          disabledForegroundColor: AppColors.secondaryText,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTypography.label,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTypography.bodySmall,
        labelStyle: AppTypography.label,
        floatingLabelStyle: AppTypography.label.copyWith(color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.mint,
        disabledColor: AppColors.surfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        labelStyle: AppTypography.label,
        secondaryLabelStyle: AppTypography.label,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.secondaryText.withValues(alpha: 0.35),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: AppTypography.headline,
        contentTextStyle: AppTypography.body,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.white),
        actionTextColor: AppColors.mint,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.mint,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.label.copyWith(color: AppColors.primary);
          }
          return AppTypography.label.copyWith(color: AppColors.secondaryText);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.secondaryText);
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
