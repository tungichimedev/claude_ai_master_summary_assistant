import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Convenience extension on [BuildContext] for quick color access.
///
/// Usage:
/// ```dart
/// final primary = context.colors.primary;
/// final bg = context.colors.background;
/// ```
///
/// All values are theme-aware: they automatically resolve to light or dark
/// palette depending on the current [ThemeData.brightness].
extension AppColorContext on BuildContext {
  AppColorAccessor get colors => AppColorAccessor(this);
}

class AppColorAccessor {
  /// Do not instantiate directly. Use `context.colors` instead.
  AppColorAccessor(BuildContext context)
      : _theme = Theme.of(context),
        _scheme = Theme.of(context).colorScheme,
        _ext = Theme.of(context).extension<AppColors>()!;

  final ThemeData _theme;
  final ColorScheme _scheme;
  final AppColors _ext;

  // --- Brand ---
  Color get primary => _scheme.primary;
  Color get onPrimary => _scheme.onPrimary;
  Color get primaryLight => _ext.primaryLight;
  Color get primaryDark => _ext.primaryDark;
  Color get accent => _ext.accent;
  Color get secondary => _scheme.secondary;

  // --- Semantic ---
  Color get success => _ext.success;
  Color get warning => _ext.warning;
  Color get error => _scheme.error;
  Color get onError => _scheme.onError;

  // --- Surfaces ---
  Color get background => _theme.scaffoldBackgroundColor;
  Color get surface => _scheme.surface;
  Color get card => _theme.cardTheme.color ?? _scheme.surface;

  // --- Text ---
  Color get text => _scheme.onSurface;
  Color get textSecondary => _ext.textSecondary;
  Color get textTertiary => _ext.textTertiary;

  // --- Misc ---
  Color get border => _ext.border;
  Color get divider => _theme.dividerTheme.color ?? _ext.border;

  // --- Shadows ---
  List<BoxShadow> get cardShadow => _ext.cardShadow;

  // --- Helpers ---
  bool get isDark => _theme.brightness == Brightness.dark;

  /// Returns [light] in light mode and [dark] in dark mode.
  T adaptive<T>(T light, T dark) => isDark ? dark : light;
}

/// Extension on [ThemeData] for use outside the widget tree (e.g. in
/// painters, overlays, or tests where you already have a ThemeData instance).
extension AppColorsThemeData on ThemeData {
  AppColors get appColors => extension<AppColors>()!;
}
