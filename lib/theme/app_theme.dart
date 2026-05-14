import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Color palette (matches PRD + prototype CSS variables)
// ---------------------------------------------------------------------------

class AppPalette {
  AppPalette._();

  // Brand
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);
  static const Color accent = Color(0xFF00D2D3);

  // Semantic
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);

  // Light mode
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF546A76);
  static const Color lightTextTertiary = Color(0xFF6B7C8D);
  static const Color lightBorder = Color(0xFFE9ECEF);

  // Dark mode
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF25274D);
  static const Color darkText = Color(0xFFEAEAEA);
  static const Color darkTextSecondary = Color(0xFFA8A8B3);
  static const Color darkTextTertiary = Color(0xFF9090A0);
  static const Color darkBorder = Color(0xFF3A3A4A);
}

// ---------------------------------------------------------------------------
// Border radius constants
// ---------------------------------------------------------------------------

class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 20;
  static const double pill = 999;

  static final BorderRadius smallBorder = BorderRadius.circular(small);
  static final BorderRadius mediumBorder = BorderRadius.circular(medium);
  static final BorderRadius largeBorder = BorderRadius.circular(large);
  static final BorderRadius pillBorder = BorderRadius.circular(pill);
}

// ---------------------------------------------------------------------------
// Shadow constants
// ---------------------------------------------------------------------------

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  // Dark-mode variants (heavier shadow)
  static const List<BoxShadow> smallDark = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> mediumDark = [
    BoxShadow(
      color: Color(0x59000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> largeDark = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Gradient presets
// ---------------------------------------------------------------------------

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.primary, AppPalette.primaryLight],
  );

  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppPalette.primary,
      AppPalette.primaryDark,
      Color(0xFF2D1B69),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient accentMix = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x196C5CE7), // primary @ 10%
      Color(0x1900D2D3), // accent @ 10%
    ],
  );
}

// ---------------------------------------------------------------------------
// Custom color extension – accessible via Theme.of(context).extension
// ---------------------------------------------------------------------------

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.success,
    required this.warning,
    required this.accent,
    required this.primaryLight,
    required this.primaryDark,
    required this.cardShadow,
  });

  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color success;
  final Color warning;
  final Color accent;
  final Color primaryLight;
  final Color primaryDark;
  final List<BoxShadow> cardShadow;

  static const light = AppColors(
    textSecondary: AppPalette.lightTextSecondary,
    textTertiary: AppPalette.lightTextTertiary,
    border: AppPalette.lightBorder,
    success: AppPalette.success,
    warning: AppPalette.warning,
    accent: AppPalette.accent,
    primaryLight: AppPalette.primaryLight,
    primaryDark: AppPalette.primaryDark,
    cardShadow: AppShadows.small,
  );

  static const dark = AppColors(
    textSecondary: AppPalette.darkTextSecondary,
    textTertiary: AppPalette.darkTextTertiary,
    border: AppPalette.darkBorder,
    success: AppPalette.success,
    warning: AppPalette.warning,
    accent: AppPalette.accent,
    primaryLight: AppPalette.primaryLight,
    primaryDark: AppPalette.primaryDark,
    cardShadow: AppShadows.smallDark,
  );

  @override
  AppColors copyWith({
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? success,
    Color? warning,
    Color? accent,
    Color? primaryLight,
    Color? primaryDark,
    List<BoxShadow>? cardShadow,
  }) {
    return AppColors(
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      accent: accent ?? this.accent,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

// ---------------------------------------------------------------------------
// Text theme factory
// ---------------------------------------------------------------------------

TextTheme _buildTextTheme(Color textColor) {
  return TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: textColor,
      height: 1.2,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: textColor,
      height: 1.25,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textColor,
      height: 1.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textColor,
      height: 1.35,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.45,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: textColor,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: textColor,
      letterSpacing: 0.5,
    ),
  );
}

// ---------------------------------------------------------------------------
// AppTheme – single source of truth for light / dark ThemeData
// ---------------------------------------------------------------------------

class AppTheme {
  AppTheme._();

  // ---- Light ----
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppPalette.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      secondary: AppPalette.accent,
      onSecondary: Colors.white,
      error: AppPalette.error,
      onError: Colors.white,
      surface: AppPalette.lightSurface,
      onSurface: AppPalette.lightText,
    ),
    textTheme: _buildTextTheme(AppPalette.lightText),
    extensions: const [AppColors.light],

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.lightBackground,
      foregroundColor: AppPalette.lightText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppPalette.lightText,
        fontFamily: 'Inter',
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppPalette.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mediumBorder,
      ),
      margin: EdgeInsets.zero,
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumBorder,
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.lightText,
        side: const BorderSide(color: AppPalette.lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumBorder,
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Text button (ghost)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppPalette.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.error, width: 1.5),
      ),
      hintStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppPalette.lightTextTertiary,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.lightSurface,
      selectedColor: AppPalette.primary,
      disabledColor: AppPalette.lightBorder,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppPalette.lightTextSecondary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pillBorder,
        side: const BorderSide(color: AppPalette.lightBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      showCheckmark: false,
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPalette.lightSurface,
      selectedItemColor: AppPalette.primary,
      unselectedItemColor: AppPalette.lightTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppPalette.lightBorder,
      thickness: 1,
      space: 1,
    ),

    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppPalette.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppPalette.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.largeBorder,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPalette.lightText,
      contentTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pillBorder,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ---- Dark ----
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppPalette.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      secondary: AppPalette.accent,
      onSecondary: Colors.white,
      error: AppPalette.error,
      onError: Colors.white,
      surface: AppPalette.darkSurface,
      onSurface: AppPalette.darkText,
    ),
    textTheme: _buildTextTheme(AppPalette.darkText),
    extensions: const [AppColors.dark],

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.darkBackground,
      foregroundColor: AppPalette.darkText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppPalette.darkText,
        fontFamily: 'Inter',
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppPalette.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mediumBorder,
      ),
      margin: EdgeInsets.zero,
    ),

    // Elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumBorder,
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Outlined button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.darkText,
        side: const BorderSide(color: AppPalette.darkBorder),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mediumBorder,
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Text button (ghost)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppPalette.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppPalette.darkBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mediumBorder,
        borderSide: const BorderSide(color: AppPalette.error, width: 1.5),
      ),
      hintStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppPalette.darkTextTertiary,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppPalette.darkSurface,
      selectedColor: AppPalette.primary,
      disabledColor: AppPalette.darkBorder,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppPalette.darkTextSecondary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pillBorder,
        side: const BorderSide(color: AppPalette.darkBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      showCheckmark: false,
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPalette.darkBackground,
      selectedItemColor: AppPalette.primary,
      unselectedItemColor: AppPalette.darkTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppPalette.darkBorder,
      thickness: 1,
      space: 1,
    ),

    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppPalette.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppPalette.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.largeBorder,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPalette.darkText,
      contentTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppPalette.darkBackground,
        fontFamily: 'Inter',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pillBorder,
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
