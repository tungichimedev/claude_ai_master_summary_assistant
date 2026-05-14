import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// ============================================================================
// AppButton – primary (gradient), secondary (outline), ghost
// ============================================================================

enum AppButtonVariant { primary, secondary, ghost }
enum AppButtonSize { regular, small }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final isSmall = size == AppButtonSize.small;
    final vertPad = isSmall ? 8.0 : 14.0;
    final horizPad = isSmall ? 16.0 : 24.0;
    final fontSize = isSmall ? 13.0 : 15.0;
    final fontWeight = isSmall ? FontWeight.w600 : FontWeight.w700;
    final radius = isSmall ? AppRadius.smallBorder : AppRadius.mediumBorder;

    Widget child;

    if (isLoading) {
      child = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary
                ? Colors.white
                : colors.primary,
          ),
        ),
      );
    } else {
      final text = Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: 'Inter',
        ),
      );
      if (icon != null) {
        child = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isSmall ? 16 : 18),
            const SizedBox(width: 8),
            text,
          ],
        );
      } else {
        child = text;
      }
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return _PrimaryButtonWrapper(
          onPressed: _enabled ? onPressed : null,
          expand: expand,
          radius: radius,
          padding: EdgeInsets.symmetric(horizontal: horizPad, vertical: vertPad),
          child: child,
        );

      case AppButtonVariant.secondary:
        final button = OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: horizPad,
              vertical: vertPad,
            ),
            shape: RoundedRectangleBorder(borderRadius: radius),
            side: BorderSide(color: colors.border),
          ),
          child: child,
        );
        return expand
            ? SizedBox(width: double.infinity, child: button)
            : button;

      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: _enabled ? onPressed : null,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: horizPad,
              vertical: vertPad,
            ),
          ),
          child: child,
        );
    }
  }
}

/// Wraps a gradient background behind the primary button.
class _PrimaryButtonWrapper extends StatelessWidget {
  const _PrimaryButtonWrapper({
    required this.onPressed,
    required this.expand,
    required this.radius,
    required this.padding,
    required this.child,
  });

  final VoidCallback? onPressed;
  final bool expand;
  final BorderRadius radius;
  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: radius,
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Container(
              width: expand ? double.infinity : null,
              padding: padding,
              alignment: Alignment.center,
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// AppChip – selectable chip with active/inactive state
// ============================================================================

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        constraints: const BoxConstraints(minHeight: 40),
        decoration: BoxDecoration(
          color: selected ? AppPalette.primary : colors.surface,
          borderRadius: AppRadius.pillBorder,
          border: Border.all(
            color: selected ? AppPalette.primary : colors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : colors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// AppCard – standard card with optional shadow
// ============================================================================

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.showShadow = true,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool showShadow;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? AppRadius.mediumBorder;

    final container = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : null,
        boxShadow: showShadow ? colors.cardShadow : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }
    return container;
  }
}

// ============================================================================
// AppToast – snackbar-style notification
// ============================================================================

enum AppToastType { neutral, success, error, info }

class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.neutral,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    Color backgroundColor;
    switch (type) {
      case AppToastType.success:
        backgroundColor = AppPalette.success;
      case AppToastType.error:
        backgroundColor = AppPalette.error;
      case AppToastType.info:
        backgroundColor = AppPalette.primary;
      case AppToastType.neutral:
        backgroundColor = Theme.of(context).colorScheme.onSurface;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pillBorder,
        ),
        duration: duration,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        dismissDirection: DismissDirection.up,
      ),
    );
  }
}

// ============================================================================
// BottomSheetModal – standard bottom sheet wrapper
// ============================================================================

class BottomSheetModal extends StatelessWidget {
  const BottomSheetModal({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.padding,
  });

  final Widget child;
  final String? title;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;

  /// Opens the bottom sheet with a standard slide-up animation.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
    EdgeInsetsGeometry? padding,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (_) => BottomSheetModal(
        title: title,
        showHandle: showHandle,
        padding: padding,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: padding ?? const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: AppRadius.pillBorder,
              ),
            ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          Flexible(child: child),
        ],
      ),
    );
  }
}
