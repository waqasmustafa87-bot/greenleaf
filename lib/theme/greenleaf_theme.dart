import 'package:material_ui/material_ui.dart';

/// Green, white, and soft yellow palette for greenleaf.
class GreenleafColors {
  GreenleafColors._();

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color deepGreen = Color(0xFF1B5E20);
  static const Color leafGreen = Color(0xFF4CAF50);
  static const Color mintSurface = Color(0xFFEAF5EB);
  static const Color softMint = Color(0xFFF3FAF3);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color backgroundWhite = Color(0xFFFAFCF9);

  // Soft yellow accents for sunlight, due-today pills, and happy feedback.
  static const Color softYellow = Color(0xFFFFF6CC);
  static const Color warmYellow = Color(0xFFFFE58F);
  static const Color sunGold = Color(0xFFF5B700);
  static const Color sunText = Color(0xFF7A5600);

  // Neutral text & borders.
  static const Color textPrimary = Color(0xFF1C2B1E);
  static const Color textSecondary = Color(0xFF5D6F60);
  static const Color borderLight = Color(0xFFDCE8DD);

  // Soft grey outer backdrop for desktop/laptop browser frame.
  static const Color desktopBackdrop = Color(0xFFE8ECE9);
  static const Color phoneBezel = Color(0xFF1E2420);
}

/// Builds the Material 3 theme for greenleaf.
ThemeData buildGreenleafTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: GreenleafColors.primaryGreen,
    primary: GreenleafColors.primaryGreen,
    onPrimary: GreenleafColors.pureWhite,
    secondary: GreenleafColors.sunGold,
    onSecondary: GreenleafColors.textPrimary,
    surface: GreenleafColors.pureWhite,
    onSurface: GreenleafColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: GreenleafColors.backgroundWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: GreenleafColors.backgroundWhite,
      foregroundColor: GreenleafColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: GreenleafColors.pureWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: GreenleafColors.borderLight),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: GreenleafColors.pureWhite,
      indicatorColor: GreenleafColors.softYellow,
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? GreenleafColors.deepGreen
              : GreenleafColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: isSelected
              ? GreenleafColors.deepGreen
              : GreenleafColors.textSecondary,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: GreenleafColors.deepGreen,
      contentTextStyle: const TextStyle(
        color: GreenleafColors.pureWhite,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
