import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Library screen displaying saved summaries with search, filters,
/// usage progress, and card list.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _activeFilter = 'All';
  final _searchController = TextEditingController();

  // TODO: wire to controller
  static const _isOffline = false;
  static const _isEmpty = false;
  static const _summariesUsed = 2;
  static const _totalFree = 5;

  static const _filters = ['All', 'Articles', 'PDFs', 'Favorites'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + search + filters + usage (sticky)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Library',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search summaries...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: colors.textTertiary,
                        size: 18,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    // TODO: wire to controller — search filtering
                  ),
                  const SizedBox(height: 14),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isActive = _activeFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _activeFilter = filter);
                              // TODO: wire to controller — apply filter
                            },
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
                                filter,
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
                  const SizedBox(height: 14),

                  // Usage progress bar
                  _buildUsageBar(theme, colors),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Error state: offline banner
            if (_isOffline)
              _buildOfflineBanner(colors),

            // Content area
            Expanded(
              child: _isEmpty
                  ? _buildEmptyState(theme, colors)
                  : _buildCardList(theme, colors),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Usage bar
  // -----------------------------------------------------------------------
  Widget _buildUsageBar(ThemeData theme, AppColors colors) {
    final remaining = _totalFree - _summariesUsed;
    final progress = _summariesUsed / _totalFree;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$remaining of $_totalFree free summaries remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppPalette.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              // TODO: wire to controller — navigate to paywall
            },
            child: const Text(
              'Upgrade',
              style: TextStyle(
                fontSize: 11,
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
  // Offline banner
  // -----------------------------------------------------------------------
  Widget _buildOfflineBanner(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppPalette.error.withValues(alpha: 0.08),
          border: Border.all(
            color: AppPalette.error.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 18, color: AppPalette.error),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'No internet connection. Showing cached summaries.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.error,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: wire to controller — retry connection
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 13,
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
  // Empty state
  // -----------------------------------------------------------------------
  Widget _buildEmptyState(ThemeData theme, AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppGradients.accentMix,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.note_add_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No summaries yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Summarize your first article to start building your personal knowledge library.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: wire to controller — navigate to home / summarize tab
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Summarize Now'),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Card list
  // -----------------------------------------------------------------------
  Widget _buildCardList(ThemeData theme, AppColors colors) {
    // Placeholder data — TODO: wire to controller
    final items = [
      _LibraryItem(
        iconText: 'TC',
        iconColor: AppPalette.error,
        title: 'How Remote Work is Changing Tech Hiring in 2026',
        preview:
            '74% of tech companies now operate fully remote. Global pay bands replacing location-based salaries...',
        source: 'TechCrunch',
        date: '2h ago',
        tag: 'Tech',
        tagColor: AppPalette.primary,
      ),
      _LibraryItem(
        iconText: null,
        iconColor: AppPalette.error,
        iconIsPdf: true,
        title: 'Q1 2026 Marketing Strategy Report',
        preview:
            'Comprehensive analysis of digital marketing trends and budget allocation recommendations...',
        source: 'PDF Upload',
        date: 'Yesterday',
        tag: 'PDF',
        tagColor: AppPalette.error,
      ),
      _LibraryItem(
        iconText: 'M',
        iconColor: AppPalette.success,
        title: 'The Science of Building Better Habits',
        preview:
            'Research shows habit formation takes 66 days on average, not 21 as commonly believed...',
        source: 'Medium',
        date: 'May 12',
        tag: 'Science',
        tagColor: AppPalette.success,
      ),
      _LibraryItem(
        iconText: 'BBC',
        iconColor: const Color(0xFF0984E3),
        title: "AI Regulation: EU's Landmark Act Takes Effect",
        preview:
            "The European Union's AI Act establishes the world's first comprehensive regulatory framework...",
        source: 'BBC News',
        date: 'May 10',
        tag: 'Policy',
        tagColor: const Color(0xFF0984E3),
      ),
      _LibraryItem(
        iconText: 'Ax',
        iconColor: AppPalette.primary,
        title: 'Attention Is Still All You Need: Transformers in 2026',
        preview:
            'Survey of recent advances in transformer architecture including sparse attention and linear transformers...',
        source: 'ArXiv',
        date: 'May 8',
        tag: 'Research',
        tagColor: AppPalette.primary,
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildLibraryCard(items[index], theme, colors),
    );
  }

  Widget _buildLibraryCard(
    _LibraryItem item,
    ThemeData theme,
    AppColors colors,
  ) {
    return GestureDetector(
      onTap: () {
        // TODO: wire to controller — navigate to summary result
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.mediumBorder,
          boxShadow: colors.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: item.iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: item.iconIsPdf
                  ? const Icon(Icons.description, size: 16, color: Colors.white)
                  : Text(
                      item.iconText ?? '',
                      style: TextStyle(
                        fontSize: item.iconText != null && item.iconText!.length > 2
                            ? 10
                            : 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.preview,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        item.source,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.date,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: item.tagColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.tag,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: item.tagColor,
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
}

// ---------------------------------------------------------------------------
// Helper data class
// ---------------------------------------------------------------------------
class _LibraryItem {
  final String? iconText;
  final Color iconColor;
  final bool iconIsPdf;
  final String title;
  final String preview;
  final String source;
  final String date;
  final String tag;
  final Color tagColor;

  const _LibraryItem({
    this.iconText,
    required this.iconColor,
    this.iconIsPdf = false,
    required this.title,
    required this.preview,
    required this.source,
    required this.date,
    required this.tag,
    required this.tagColor,
  });
}
