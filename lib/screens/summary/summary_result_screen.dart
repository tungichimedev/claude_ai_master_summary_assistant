import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Displays the generated summary in multiple formats (bullets, paragraph,
/// takeaways, actions) with a sticky bottom action bar.
class SummaryResultScreen extends ConsumerStatefulWidget {
  const SummaryResultScreen({super.key});

  @override
  ConsumerState<SummaryResultScreen> createState() =>
      _SummaryResultScreenState();
}

enum _SummaryFormat { bullets, paragraph, takeaways, actions }

class _SummaryResultScreenState extends ConsumerState<SummaryResultScreen> {
  _SummaryFormat _selectedFormat = _SummaryFormat.bullets;

  // Placeholder data — TODO: wire to controller
  static const _source = 'TechCrunch';
  static const _title = 'How Remote Work is Changing Tech Hiring in 2026';
  static const _wordCount = 2347;
  static const _bulletCount = 5;
  static const _timeSavedMinutes = 16;

  static const _bullets = [
    '74% of tech companies now operate with fully remote workforces, a significant increase from 52% in 2024, driven by cost savings and talent access.',
    'Global pay bands are replacing location-based salaries, reducing salary geo-arbitrage opportunities for remote workers.',
    'AI screening tools handle 60% of initial candidate filtering, with human recruiters focusing on culture fit and soft skills.',
    'Async communication skills have become the #1 hiring criterion, surpassing traditional technical assessments.',
    'Hub offices are replacing traditional HQs, with companies investing in quarterly in-person meetups instead of permanent office space.',
  ];

  static const _paragraphText =
      "The tech industry's approach to hiring has fundamentally transformed in 2026, with 74% of companies now operating fully remote - up from 52% just two years ago. This shift has catalyzed several major changes: global pay bands are replacing location-based salaries, effectively ending the era of salary geo-arbitrage. AI screening tools now handle 60% of initial candidate filtering, freeing human recruiters to evaluate culture fit and communication skills. Perhaps most notably, asynchronous communication has emerged as the top hiring criterion, overtaking traditional technical assessments. Companies are also reimagining physical spaces, replacing permanent headquarters with \"hub offices\" that host quarterly team meetups, striking a balance between remote flexibility and in-person collaboration.";

  static const _takeaways = [
    'Remote work is no longer an experiment - it\'s the dominant model. Companies that resist will lose access to 74% of the talent pool.',
    'Soft skills beat hard skills. Invest in async communication, documentation writing, and self-management abilities.',
    'AI is reshaping recruiting. Candidates should optimize for AI screening while maintaining authentic human connections.',
  ];

  static const _actionItems = [
    'Audit your job listings for async-friendly language and remove location-biased requirements',
    'Implement AI screening tools for initial candidate filtering to save 40% recruiter time',
    'Develop global pay band framework to standardize compensation across regions',
    'Plan quarterly hub meetups and evaluate permanent office lease alternatives',
    'Add async communication assessment to your interview process',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source info header
                    _buildSourceHeader(theme, colors),
                    const SizedBox(height: 14),

                    // Format chips
                    _buildFormatChips(theme, colors),
                    const SizedBox(height: 8),

                    // Time saved
                    _buildTimeSaved(colors),
                    const SizedBox(height: 8),

                    // Content area
                    _buildContentArea(theme, colors),
                  ],
                ),
              ),
            ),
          ),

          // Sticky bottom action bar
          _buildBottomActionBar(theme, colors),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Source header
  // -----------------------------------------------------------------------
  Widget _buildSourceHeader(ThemeData theme, AppColors colors) {
    return Row(
      children: [
        // Back button
        GestureDetector(
          onTap: () {
            // TODO: wire to controller — go back to home
            Navigator.of(context).maybePop();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back,
              size: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Source info
        Expanded(
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppPalette.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'TC',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _source,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$_wordCount words -> $_bulletCount key points',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        // Saved badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppPalette.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Saved',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppPalette.success,
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Format chips
  // -----------------------------------------------------------------------
  Widget _buildFormatChips(ThemeData theme, AppColors colors) {
    return Row(
      children: [
        Text(
          'View as:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _SummaryFormat.values.map((format) {
                final isActive = _selectedFormat == format;
                final label = switch (format) {
                  _SummaryFormat.bullets => 'Bullets',
                  _SummaryFormat.paragraph => 'Paragraph',
                  _SummaryFormat.takeaways => 'Takeaways',
                  _SummaryFormat.actions => 'Actions',
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFormat = format),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      constraints: const BoxConstraints(minHeight: 40),
                      decoration: BoxDecoration(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                        borderRadius: AppRadius.pillBorder,
                        border: Border.all(
                          color: isActive
                              ? theme.colorScheme.primary
                              : colors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Time saved
  // -----------------------------------------------------------------------
  Widget _buildTimeSaved(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 14,
              color: colors.success,
            ),
            const SizedBox(width: 6),
            Text(
              '$_timeSavedMinutes min saved today',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Content area — switches based on selected format
  // -----------------------------------------------------------------------
  Widget _buildContentArea(ThemeData theme, AppColors colors) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(_selectedFormat),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.mediumBorder,
          boxShadow: colors.cardShadow,
        ),
        child: switch (_selectedFormat) {
          _SummaryFormat.bullets => _buildBulletsContent(theme, colors),
          _SummaryFormat.paragraph => _buildParagraphContent(theme, colors),
          _SummaryFormat.takeaways => _buildTakeawaysContent(theme, colors),
          _SummaryFormat.actions => _buildActionsContent(theme, colors),
        },
      ),
    );
  }

  // -- Bullets --
  Widget _buildBulletsContent(ThemeData theme, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        ...List.generate(_bullets.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _bullets[index],
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
                const SizedBox(width: 10),
                // Share insight button
                GestureDetector(
                  onTap: () {
                    // TODO: wire to controller — copy/share insight
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Insight copied! Share it anywhere.'),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(
                      Icons.north_east_rounded,
                      size: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // -- Paragraph --
  Widget _buildParagraphContent(ThemeData theme, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Text(
          _paragraphText,
          style: TextStyle(
            fontSize: 14,
            height: 1.7,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // -- Takeaways --
  Widget _buildTakeawaysContent(ThemeData theme, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Takeaways',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...List.generate(_takeaways.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                border: Border(
                  left: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TAKEAWAY ${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _takeaways[index],
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // -- Actions --
  Widget _buildActionsContent(ThemeData theme, AppColors colors) {
    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Action Items',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...List.generate(_actionItems.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: false, // TODO: wire to controller
                        onChanged: (val) {
                          // TODO: wire to controller — toggle action item
                        },
                        activeColor: theme.colorScheme.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: wire to controller — toggle action item
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _actionItems[index],
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // -----------------------------------------------------------------------
  // Sticky bottom action bar
  // -----------------------------------------------------------------------
  Widget _buildBottomActionBar(ThemeData theme, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomAction(
                icon: Icons.bookmark_border_rounded,
                label: 'Save',
                onTap: () {
                  // TODO: wire to controller — save to library
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to Library!')),
                  );
                },
              ),
              _BottomAction(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  // TODO: wire to controller — open share sheet
                },
              ),
              _BottomAction(
                icon: Icons.grid_view_rounded,
                label: 'Card',
                onTap: () {
                  // TODO: wire to controller — navigate to card creator
                },
              ),
              _BottomAction(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: () {
                  // TODO: wire to controller — copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard!')),
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
// Bottom action button
// ---------------------------------------------------------------------------
class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: colors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
