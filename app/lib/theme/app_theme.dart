import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

TextStyle _deva(double size, double height, FontWeight w, [Color c = AppColors.textPrimary]) =>
    GoogleFonts.notoSansDevanagari(fontSize: size, height: height / size, fontWeight: w, color: c);
TextStyle _inter(double size, double height, FontWeight w, [Color c = AppColors.textPrimary]) =>
    GoogleFonts.inter(fontSize: size, height: height / size, fontWeight: w, color: c);

/// Text roles from DESIGN_SYSTEM.md. Devanagari-capable family is the base so
/// Hindi/Sanskrit never falls back to a mismatched font.
abstract final class AppText {
  static final display = _deva(32, 40, FontWeight.w700);
  static final screenTitle = _deva(24, 32, FontWeight.w600);
  static final sectionTitle = _deva(20, 28, FontWeight.w600);
  static final shlokFeed = _deva(21, 34, FontWeight.w600);
  static final shlokReader = _deva(24, 40, FontWeight.w600);
  static final meaningFeed = _deva(16, 26, FontWeight.w400);
  static final body = _deva(16, 26, FontWeight.w400);
  static final label = _inter(14, 20, FontWeight.w600);
  static final metadata = _inter(12, 18, FontWeight.w500, AppColors.textSecondary);
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.actionYellow,
    onPrimary: AppColors.onAction,
    secondary: AppColors.gold,
    onSecondary: AppColors.onAction,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.canvas,
  );
  final textTheme = TextTheme(
    displaySmall: AppText.display,
    headlineSmall: AppText.screenTitle,
    titleMedium: AppText.sectionTitle,
    bodyLarge: AppText.body,
    bodyMedium: AppText.body,
    labelLarge: AppText.label,
    bodySmall: AppText.metadata,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.canvas,
    textTheme: textTheme,
    extensions: const [GeetaColors()],
    dividerColor: AppColors.divider,
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: AppSpacing.iconSize),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        backgroundColor: AppColors.actionYellow,
        foregroundColor: AppColors.onAction,
        disabledBackgroundColor: AppColors.surfacePressed,
        textStyle: AppText.label,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.divider),
        shape: const StadiumBorder(),
        textStyle: AppText.label,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
        foregroundColor: AppColors.gold,
        textStyle: AppText.label,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.surfacePressed,
      side: const BorderSide(color: AppColors.divider),
      labelStyle: AppText.label,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceRaised,
      hintStyle: AppText.body.copyWith(color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
      errorStyle: AppText.metadata.copyWith(color: AppColors.error),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      dragHandleColor: AppColors.divider,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceRaised,
      contentTextStyle: AppText.body.copyWith(fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.textPrimary,
      textColor: AppColors.textPrimary,
      minVerticalPadding: AppSpacing.s2,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.onAction : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? AppColors.actionYellow : AppColors.surfaceRaised,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.canvas,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.screenTitle,
    ),
  );
}
