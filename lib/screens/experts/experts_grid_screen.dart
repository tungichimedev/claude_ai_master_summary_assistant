import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Grid screen displaying available AI expert personas.
///
/// Active experts (Social Media, Fitness) are tappable and navigate to chat.
/// Locked experts show a lock icon with "Coming Soon" and tap opens paywall.
class ExpertsGridScreen extends ConsumerWidget {
  const ExpertsGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    // Placeholder data — TODO: wire to controller
    final experts = [
      _ExpertData(
        emoji: '\u{1F4F1}',
        name: 'Social Media',
        subtitle: 'Expert',
        description: 'Captions, hashtags & strategy',
        gradientColors: const [Color(0xFF0984E3), Color(0xFF74B9FF)],
        isLocked: false,
        isComingSoon: false,
      ),
      _ExpertData(
        emoji: '\u{1F4AA}',
        name: 'Fitness Coach',
        subtitle: 'Coach',
        description: 'Workouts & nutrition plans',
        gradientColors: const [Color(0xFF00B894), Color(0xFF55EFC4)],
        isLocked: false,
        isComingSoon: false,
      ),
      _ExpertData(
        emoji: '\u{1F953}',
        name: 'Expert Chef',
        subtitle: 'Coming Soon',
        description: 'Recipes & meal plans',
        gradientColors: const [Color(0xFFE17055), Color(0xFFFAB1A0)],
        isLocked: true,
        isComingSoon: true,
      ),
      _ExpertData(
        emoji: '\u{1F3E0}',
        name: 'Home Advisor',
        subtitle: 'Locked',
        description: 'DIY & home improvement',
        gradientColors: const [Color(0xFF00CEC9), Color(0xFF81ECEC)],
        isLocked: true,
        isComingSoon: false,
      ),
      _ExpertData(
        emoji: '\u{1F4B0}',
        name: 'Sales Coach',
        subtitle: 'Locked',
        description: 'Pitch & negotiation',
        gradientColors: const [Color(0xFFE84393), Color(0xFFFD79A8)],
        isLocked: true,
        isComingSoon: false,
      ),
      _ExpertData(
        emoji: '\u{270D}\u{FE0F}',
        name: 'Writing',
        subtitle: 'Locked',
        description: 'Emails, essays & more',
        gradientColors: const [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
        isLocked: true,
        isComingSoon: false,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Experts',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Specialized AI coaches for every need',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // 2-column grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: experts.length,
                itemBuilder: (context, index) {
                  return _ExpertCard(
                    expert: experts[index],
                    onTap: () {
                      if (experts[index].isLocked) {
                        // TODO: wire to controller — show paywall bottom sheet
                      } else {
                        // TODO: wire to controller — navigate to expert chat
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expert card widget
// ---------------------------------------------------------------------------
class _ExpertCard extends StatelessWidget {
  final _ExpertData expert;
  final VoidCallback onTap;

  const _ExpertCard({
    required this.expert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: expert.isLocked ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.mediumBorder,
            boxShadow: colors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient header
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: expert.gradientColors,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 20, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expert.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              expert.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              expert.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lock icon for locked experts
                      if (expert.isLocked)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.lock,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Description footer
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  expert.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper data class
// ---------------------------------------------------------------------------
class _ExpertData {
  final String emoji;
  final String name;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;
  final bool isLocked;
  final bool isComingSoon;

  const _ExpertData({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
    required this.isLocked,
    required this.isComingSoon,
  });
}
