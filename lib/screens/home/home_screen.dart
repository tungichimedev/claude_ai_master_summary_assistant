import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Main home screen with summarization input, clipboard banner,
/// summary of the day, and recent summaries.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _inputTabController;
  final bool _clipboardBannerVisible = true;

  // TODO: wire to controller
  static const _userName = 'John';
  static const _streakCount = 12;
  static const _remainingSummaries = 3;
  static const _totalFreeSummaries = 5;

  @override
  void initState() {
    super.initState();
    _inputTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _inputTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting header + streak badge
              _buildGreetingHeader(theme, colors),
              const SizedBox(height: 12),

              // Clipboard detection banner
              if (_clipboardBannerVisible) ...[
                _buildClipboardBanner(colors),
                const SizedBox(height: 16),
              ],

              // Input card with tabs
              _buildInputCard(theme, colors),
              const SizedBox(height: 12),

              // Usage counter
              _buildUsageCounter(colors),
              const SizedBox(height: 20),

              // Summary of the Day
              _buildSummaryOfTheDay(theme, colors),
              const SizedBox(height: 20),

              // Recent Summaries
              _buildRecentSummaries(theme, colors),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Greeting header
  // -----------------------------------------------------------------------
  Widget _buildGreetingHeader(ThemeData theme, AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        // Streak badge
        GestureDetector(
          onTap: () {
            // TODO: wire to controller — navigate to profile
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppPalette.error.withValues(alpha: 0.1),
              borderRadius: AppRadius.pillBorder,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  '$_streakCount',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.error,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'day streak',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppPalette.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Clipboard banner
  // -----------------------------------------------------------------------
  Widget _buildClipboardBanner(AppColors colors) {
    return GestureDetector(
      onTap: () {
        // TODO: wire to controller — summarize clipboard content
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.content_paste_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summarize copied article?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'techcrunch.com/2026/05/remote-work-hiring...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Summarize',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Input card with tabs
  // -----------------------------------------------------------------------
  Widget _buildInputCard(ThemeData theme, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mediumBorder,
        boxShadow: colors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab bar
          TabBar(
            controller: _inputTabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: colors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 2,
            dividerColor: colors.border,
            tabs: const [
              Tab(text: 'Text'),
              Tab(text: 'URL'),
              Tab(text: 'PDF'),
            ],
          ),

          // Tab views
          SizedBox(
            height: 130,
            child: TabBarView(
              controller: _inputTabController,
              children: [
                // Text tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Paste any text to summarize...',
                      border: OutlineInputBorder(),
                    ),
                    // TODO: wire to controller
                  ),
                ),

                // URL tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/article',
                      border: OutlineInputBorder(),
                    ),
                    // TODO: wire to controller
                  ),
                ),

                // PDF tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {
                      // TODO: wire to controller — open file picker or show paywall
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.border,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        borderRadius: AppRadius.mediumBorder,
                      ),
                      child: DashedBorderPainter(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 32,
                              color: colors.textTertiary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to upload PDF',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Up to 30 pages',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Summarize button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: wire to controller — start summarization
                  },
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('Summarize'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Usage counter
  // -----------------------------------------------------------------------
  Widget _buildUsageCounter(AppColors colors) {
    final isWarning = _remainingSummaries <= 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.pillBorder,
        border: Border.all(
          color: isWarning ? AppPalette.warning : colors.border,
        ),
      ),
      child: Row(
        children: [
          // Usage ring
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: _remainingSummaries / _totalFreeSummaries,
              strokeWidth: 2.5,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isWarning ? AppPalette.error : AppPalette.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$_remainingSummaries of $_totalFreeSummaries free summaries remaining',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWarning ? AppPalette.error : colors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: wire to controller — navigate to paywall
            },
            child: const Text(
              'Pro',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppPalette.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Summary of the Day
  // -----------------------------------------------------------------------
  Widget _buildSummaryOfTheDay(ThemeData theme, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Summary of the Day',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              'Trending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // TODO: wire to controller — navigate to summary result
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppRadius.mediumBorder,
              boxShadow: colors.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Source icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.public,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BBC News',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "AI Regulation: EU's Landmark Act Takes Effect",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "The EU AI Act establishes the world's first comprehensive framework for regulating artificial intelligence...",
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTag('5 min read', colors),
                                const SizedBox(width: 6),
                                _buildTag('Technology', colors),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // HOT badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: AppPalette.warning,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'HOT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Recent Summaries
  // -----------------------------------------------------------------------
  Widget _buildRecentSummaries(ThemeData theme, AppColors colors) {
    // Placeholder data
    const recentItems = [
      _RecentItem('TC', Color(0xFFE17055), '2h ago', 'How Remote Work is Changing Tech Hiring', '5 key points'),
      _RecentItem('M', Color(0xFF00B894), 'Yesterday', 'The Science of Building Better Habits', '4 key points'),
      _RecentItem('Ax', Color(0xFF6C5CE7), '2d ago', 'Transformer Architecture Advances 2026', '6 key points'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Summaries',
              style: theme.textTheme.titleMedium,
            ),
            GestureDetector(
              onTap: () {
                // TODO: wire to controller — navigate to library
              },
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: recentItems.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = recentItems[index];
              return _buildRecentCard(item, theme, colors);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCard(_RecentItem item, ThemeData theme, AppColors colors) {
    return GestureDetector(
      onTap: () {
        // TODO: wire to controller — navigate to summary result
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.mediumBorder,
          boxShadow: colors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: item.iconColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.iconText,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  item.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 11,
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper data class for recent summaries
// ---------------------------------------------------------------------------
class _RecentItem {
  final String iconText;
  final Color iconColor;
  final String timeAgo;
  final String title;
  final String subtitle;

  const _RecentItem(
    this.iconText,
    this.iconColor,
    this.timeAgo,
    this.title,
    this.subtitle,
  );
}

// ---------------------------------------------------------------------------
// Simple dashed border placeholder (for PDF upload area)
// ---------------------------------------------------------------------------
class DashedBorderPainter extends StatelessWidget {
  final Widget child;

  const DashedBorderPainter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Using a simple container — a proper dashed border would use CustomPaint.
    // For now, the parent already has a border.
    return child;
  }
}
