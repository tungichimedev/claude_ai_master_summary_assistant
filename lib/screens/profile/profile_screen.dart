import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Profile screen showing user info, stats, streak calendar,
/// subscription status, and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Placeholder data — TODO: wire to controller
  static const _userName = 'John Doe';
  static const _userEmail = 'john@example.com';
  static const _userInitials = 'JD';
  static const _summaryCount = 47;
  static const _hoursSaved = '3.5h';
  static const _streakDays = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            children: [
              // Avatar + name + email
              _buildUserHeader(theme, colors),
              const SizedBox(height: 24),

              // Stats row
              _buildStatsRow(theme, colors),
              const SizedBox(height: 20),

              // Streak calendar
              _buildStreakCalendar(theme, colors),
              const SizedBox(height: 16),

              // Subscription card
              _buildSubscriptionCard(theme, colors),
              const SizedBox(height: 12),

              // Invite friends card
              _buildInviteFriendsCard(theme, colors),
              const SizedBox(height: 12),

              // Settings list
              _buildSettingsList(theme, colors),
              const SizedBox(height: 12),

              // Rate + Share
              _buildRateShareRow(theme, colors),
              const SizedBox(height: 16),

              // Version
              Text(
                'AI Master v1.0.2 (Build 3)',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // User header
  // -----------------------------------------------------------------------
  Widget _buildUserHeader(ThemeData theme, AppColors colors) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            gradient: AppGradients.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            _userInitials,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          _userEmail,
          style: TextStyle(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Stats row
  // -----------------------------------------------------------------------
  Widget _buildStatsRow(ThemeData theme, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          _buildStatCell(
            value: '$_summaryCount',
            label: 'Summaries',
            color: theme.colorScheme.primary,
            colors: colors,
          ),
          Container(width: 1, height: 48, color: colors.border),
          _buildStatCell(
            value: _hoursSaved,
            label: 'Saved',
            color: colors.success,
            colors: colors,
          ),
          Container(width: 1, height: 48, color: colors.border),
          _buildStatCell(
            value: '$_streakDays',
            label: 'Day Streak',
            color: AppPalette.error,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell({
    required String value,
    required String label,
    required Color color,
    required AppColors colors,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Streak calendar (last 14 days, shown as 2 weeks)
  // -----------------------------------------------------------------------
  Widget _buildStreakCalendar(ThemeData theme, AppColors colors) {
    // Placeholder: 12 active days, 1 missed (index 5), today is partial (index 11)
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F'];
    const activeIndices = {0, 1, 2, 3, 4, 6, 7, 8, 9, 10};
    const missedIndex = 5;
    const todayIndex = 11;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mediumBorder,
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activity Streak',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text('🔥', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dayLabels.length, (index) {
              final isActive = activeIndices.contains(index);
              final isMissed = index == missedIndex;
              final isToday = index == todayIndex;

              Color bgColor;
              Border? border;

              if (isActive) {
                bgColor = theme.colorScheme.primary;
              } else if (isMissed) {
                bgColor = colors.primaryLight.withValues(alpha: 0.5);
              } else if (isToday) {
                bgColor = theme.colorScheme.primary.withValues(alpha: 0.15);
                border = Border.all(
                  color: colors.primaryLight,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                );
              } else {
                bgColor = colors.border;
              }

              return Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: isToday ? border : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Subscription card
  // -----------------------------------------------------------------------
  Widget _buildSubscriptionCard(ThemeData theme, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mediumBorder,
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Free Plan \u2014 3 of 5 summaries remaining', // TODO: wire to controller
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: wire to controller — navigate to paywall
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Upgrade to Pro'),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Invite friends card
  // -----------------------------------------------------------------------
  Widget _buildInviteFriendsCard(ThemeData theme, AppColors colors) {
    return GestureDetector(
      onTap: () {
        // TODO: wire to controller — navigate to referral screen
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppGradients.accentMix,
          borderRadius: AppRadius.mediumBorder,
          boxShadow: colors.cardShadow,
        ),
        child: Row(
          children: [
            const Text('\u{1F381}', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Invite Friends',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Give 5 summaries, get 5 free',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Settings list
  // -----------------------------------------------------------------------
  Widget _buildSettingsList(ThemeData theme, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mediumBorder,
        boxShadow: colors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Dark Mode toggle
          _SettingsRow(
            icon: Icons.settings_outlined,
            label: 'Dark Mode',
            trailing: Switch(
              value: theme.brightness == Brightness.dark,
              onChanged: (val) {
                // TODO: wire to controller — toggle dark mode
              },
              activeTrackColor: theme.colorScheme.primary,
            ),
            showDivider: true,
            colors: colors,
          ),
          _SettingsRow(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            onTap: () {
              // TODO: wire to controller
            },
            showDivider: true,
            colors: colors,
          ),
          _SettingsRow(
            icon: Icons.lock_outline_rounded,
            label: 'Privacy',
            onTap: () {
              // TODO: wire to controller
            },
            showDivider: true,
            colors: colors,
          ),
          _SettingsRow(
            icon: Icons.help_outline_rounded,
            label: 'Help & FAQ',
            onTap: () {
              // TODO: wire to controller
            },
            showDivider: true,
            colors: colors,
          ),
          _SettingsRow(
            icon: Icons.info_outline_rounded,
            label: 'About',
            onTap: () {
              // TODO: wire to controller
            },
            showDivider: false,
            colors: colors,
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Rate + Share
  // -----------------------------------------------------------------------
  Widget _buildRateShareRow(ThemeData theme, AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: wire to controller — rate app
            },
            icon: const Text('\u2B50', style: TextStyle(fontSize: 13)),
            label: const Text('Rate Us', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: wire to controller — share app
            },
            icon: const Text('\u{1F517}', style: TextStyle(fontSize: 13)),
            label: const Text('Share App', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Settings row widget
// ---------------------------------------------------------------------------
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final AppColors colors;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    required this.showDivider,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: colors.textTertiary,
                    ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: colors.border, indent: 16, endIndent: 16),
      ],
    );
  }
}
