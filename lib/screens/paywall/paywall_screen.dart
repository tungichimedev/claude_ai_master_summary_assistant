import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Full-screen hard paywall with purple gradient header, feature comparison,
/// plan selection, social proof, and CTA.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

enum _PlanType { weekly, monthly, annual }

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  _PlanType _selectedPlan = _PlanType.annual;

  String get _priceText => switch (_selectedPlan) {
        _PlanType.weekly => 'Then \$3.99/week. Cancel anytime.',
        _PlanType.monthly => 'Then \$9.99/month. Cancel anytime.',
        _PlanType.annual => 'Then \$59.99/year. Cancel anytime.',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Purple gradient header
            _buildHeader(theme),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 3 feature bullets
                  _buildFeatureBullets(theme, colors),
                  const SizedBox(height: 24),

                  // Urgency badge
                  _buildUrgencyBadge(),
                  const SizedBox(height: 16),

                  // Free vs Pro comparison table
                  _buildComparisonTable(theme, colors),
                  const SizedBox(height: 20),

                  // 3 plan cards
                  _buildPlanCards(theme, colors),
                  const SizedBox(height: 20),

                  // Social proof
                  _buildSocialProof(theme, colors),
                  const SizedBox(height: 16),

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
                          // TODO: wire to controller — start purchase / trial
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

                  // Price transparency
                  Text(
                    _priceText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Restore + Terms
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: wire to controller — restore purchases
                        },
                        child: const Text(
                          'Restore Purchases',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppPalette.primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '|',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: wire to controller — show terms
                        },
                        child: const Text(
                          'Terms',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppPalette.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Purple gradient header
  // -----------------------------------------------------------------------
  Widget _buildHeader(ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            24,
            MediaQuery.of(context).padding.top + 24,
            24,
            32,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppPalette.primary, AppPalette.primaryDark],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Save hours every week',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Summarize anything. No limits.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        // Close button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 16,
          child: GestureDetector(
            onTap: () {
              // TODO: wire to controller — dismiss paywall
              Navigator.of(context).maybePop();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Feature bullets
  // -----------------------------------------------------------------------
  Widget _buildFeatureBullets(ThemeData theme, AppColors colors) {
    final features = [
      (
        'Unlimited Summaries',
        'Any article, PDF, or link',
        Icons.check_circle_outline,
        theme.colorScheme.primary,
        theme.colorScheme.primary.withValues(alpha: 0.1),
      ),
      (
        'All AI Experts',
        'Fitness, social media, chef & more',
        Icons.group_outlined,
        colors.success,
        colors.success.withValues(alpha: 0.1),
      ),
      (
        'Shareable Cards',
        'Export beautiful summary cards',
        Icons.grid_view_rounded,
        colors.accent,
        colors.accent.withValues(alpha: 0.1),
      ),
    ];

    return Column(
      children: features.map((f) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: f.$5,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(f.$3, size: 20, color: f.$4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.$1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // -----------------------------------------------------------------------
  // Urgency badge
  // -----------------------------------------------------------------------
  Widget _buildUrgencyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: AppPalette.warning.withValues(alpha: 0.15),
        border: Border.all(
          color: AppPalette.warning.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '\u26A1 LAUNCH PRICING \u2014 INTRODUCTORY RATE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE67E22),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Comparison table
  // -----------------------------------------------------------------------
  Widget _buildComparisonTable(ThemeData theme, AppColors colors) {
    final rows = [
      ('Summaries', '5 total', '\u2713 Unlimited'),
      ('PDF upload', '\u2717', '\u2713 30 pages'),
      ('AI Experts', '2', '\u2713 All 6'),
      ('Offline library', '20', '\u2713 Unlimited'),
      ('Summary cards', '\u2717', '\u2713'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Feature',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Free',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Pro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...rows.map((row) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      row.$3,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.success,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Plan cards
  // -----------------------------------------------------------------------
  Widget _buildPlanCards(ThemeData theme, AppColors colors) {
    return Column(
      children: [
        _PlanCard(
          type: _PlanType.weekly,
          title: 'Weekly',
          subtitle: 'Flexible, cancel anytime',
          price: '\$3.99',
          period: '/week',
          isSelected: _selectedPlan == _PlanType.weekly,
          onTap: () => setState(() => _selectedPlan = _PlanType.weekly),
          colors: colors,
          theme: theme,
        ),
        const SizedBox(height: 10),
        _PlanCard(
          type: _PlanType.monthly,
          title: 'Monthly',
          subtitle: '\$9.99 billed monthly',
          price: '\$9.99',
          period: '/month',
          isSelected: _selectedPlan == _PlanType.monthly,
          onTap: () => setState(() => _selectedPlan = _PlanType.monthly),
          colors: colors,
          theme: theme,
        ),
        const SizedBox(height: 10),
        _PlanCard(
          type: _PlanType.annual,
          title: 'Annual',
          subtitle: '\$4.99/mo billed yearly',
          price: '\$59.99',
          period: '/year',
          isSelected: _selectedPlan == _PlanType.annual,
          badges: const ['BEST VALUE', 'SAVE 50%'],
          onTap: () => setState(() => _selectedPlan = _PlanType.annual),
          colors: colors,
          theme: theme,
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Social proof
  // -----------------------------------------------------------------------
  Widget _buildSocialProof(ThemeData theme, AppColors colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('\u2B50', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          const Text(
            '127,000+ articles summarized',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'by our community',
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan card widget
// ---------------------------------------------------------------------------
class _PlanCard extends StatelessWidget {
  final _PlanType type;
  final String title;
  final String subtitle;
  final String price;
  final String period;
  final bool isSelected;
  final List<String>? badges;
  final VoidCallback onTap;
  final AppColors colors;
  final ThemeData theme;

  const _PlanCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.period,
    required this.isSelected,
    this.badges,
    required this.onTap,
    required this.colors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.05)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : colors.border,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badges
          if (badges != null)
            Positioned(
              top: -10,
              right: 12,
              child: Row(
                children: badges!.map((badge) {
                  final color = badge == 'BEST VALUE'
                      ? AppPalette.success
                      : AppPalette.primary;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
