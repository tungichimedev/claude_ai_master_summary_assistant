import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Soft paywall shown as a modal bottom sheet after the user's 2nd summary.
///
/// Displays a personalized message about time saved, benefit checkmarks,
/// trial CTA, and dismiss option.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const SoftPaywallSheet(),
/// );
/// ```
class SoftPaywallSheet extends ConsumerWidget {
  const SoftPaywallSheet({super.key});

  // Placeholder data — TODO: wire to controller
  static const _wordCount = 2347;
  static const _secondsElapsed = 6;
  static const _minutesSaved = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.bolt,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Headline
          Text(
            'You just summarized $_wordCount words in $_secondsElapsed seconds',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),

          // Time saved stat
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
                fontFamily: 'Inter',
              ),
              children: [
                const TextSpan(text: "That's "),
                TextSpan(
                  text: '$_minutesSaved minutes saved',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // "Imagine unlimited"
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 15,
                color: colors.textSecondary,
              ),
              children: const [
                TextSpan(text: 'Imagine '),
                TextSpan(
                  text: 'unlimited',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' summaries.'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Benefit checkmarks
          _BenefitRow(label: 'Unlimited summaries', colors: colors),
          const SizedBox(height: 8),
          _BenefitRow(label: 'PDF & document upload', colors: colors),
          const SizedBox(height: 8),
          _BenefitRow(label: 'All AI Expert coaches', colors: colors),
          const SizedBox(height: 24),

          // CTA
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: wire to controller — start trial / navigate to trial active
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Start 7-Day Free Trial'),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Price text
          Text(
            'Then \$9.99/mo. Cancel anytime.',
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),

          // Maybe later
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(48, 48),
            ),
            child: Text(
              'Maybe later',
              style: TextStyle(
                fontSize: 13,
                color: colors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Benefit row with green checkmark
// ---------------------------------------------------------------------------
class _BenefitRow extends StatelessWidget {
  final String label;
  final AppColors colors;

  const _BenefitRow({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '\u2713',
          style: TextStyle(
            fontSize: 18,
            color: colors.success,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
