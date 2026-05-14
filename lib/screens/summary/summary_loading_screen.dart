import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Loading screen shown while a summary is being generated.
///
/// Displays source info, animated shimmer skeletons, a progress bar,
/// and cycling status text. Auto-navigates to the result screen when done.
class SummaryLoadingScreen extends ConsumerStatefulWidget {
  const SummaryLoadingScreen({super.key});

  @override
  ConsumerState<SummaryLoadingScreen> createState() =>
      _SummaryLoadingScreenState();
}

class _SummaryLoadingScreenState extends ConsumerState<SummaryLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  int _statusIndex = 0;

  static const _statusMessages = [
    'Reading the article...',
    'Extracting key insights...',
    'Organizing summary...',
    'Almost done...',
  ];

  // Placeholder source data — TODO: wire to controller
  static const _sourceName = 'techcrunch.com';
  static const _sourceTitle = 'How Remote Work is Changing...';
  static const _wordCount = 2347;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    // Cycle status messages
    _cycleStatusMessages();

    // Auto-navigate after loading completes
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // TODO: wire to controller — navigate to summary result screen
      }
    });
  }

  void _cycleStatusMessages() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _statusIndex = (_statusIndex + 1).clamp(0, _statusMessages.length - 1);
      });
      if (_statusIndex < _statusMessages.length - 1) {
        _cycleStatusMessages();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back / cancel button
              _BackButton(
                onTap: () {
                  // TODO: wire to controller — cancel summarization, go back
                  Navigator.of(context).maybePop();
                },
              ),
              const SizedBox(height: 12),

              // Source info + progress + shimmer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.mediumBorder,
                  boxShadow: colors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source row
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppPalette.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'TC',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _sourceName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textTertiary,
                                ),
                              ),
                              const Text(
                                _sourceTitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Spinner + analyzing text
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Summarizing... analyzing $_wordCount words',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Progress bar
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            minHeight: 6,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Shimmer skeleton lines
                    ..._buildShimmerLines(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status text
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _statusMessages[_statusIndex],
                    key: ValueKey(_statusIndex),
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildShimmerLines() {
    final widths = [0.65, 1.0, 0.9, 0.95, 0.8, 0.85, 1.0, 0.75, 0.88];
    return widths.map((w) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ShimmerLine(widthFraction: w),
      );
    }).toList();
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

class _ShimmerLine extends StatefulWidget {
  final double widthFraction;
  final double height;

  const _ShimmerLine({
    required this.widthFraction,
    // ignore: unused_element_parameter
    this.height = 14,
  });

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF25274D) : const Color(0xFFEEEEEE);
    final highlightColor =
        isDark ? const Color(0xFF2E3050) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widget.widthFraction,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
                end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
                colors: [baseColor, highlightColor, baseColor],
              ),
            ),
          ),
        );
      },
    );
  }
}
