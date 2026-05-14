import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';

/// Chat screen for interacting with a specific AI expert.
///
/// Displays structured output cards for AI responses (not plain chat bubbles)
/// and standard chat bubbles for user messages. Includes cross-expert referral
/// banner and input bar.
class ExpertChatScreen extends ConsumerStatefulWidget {
  /// The type of expert to display. Determines header styling,
  /// placeholder messages, and structured output format.
  final ExpertChatType expertType;

  const ExpertChatScreen({
    super.key,
    required this.expertType,
  });

  @override
  ConsumerState<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

/// Supported expert types for this chat screen.
enum ExpertChatType { fitness, socialMedia }

class _ExpertChatScreenState extends ConsumerState<ExpertChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Expert config based on type
  String get _expertName => switch (widget.expertType) {
        ExpertChatType.fitness => 'Fitness Coach',
        ExpertChatType.socialMedia => 'Social Media Expert',
      };

  String get _expertEmoji => switch (widget.expertType) {
        ExpertChatType.fitness => '\u{1F4AA}',
        ExpertChatType.socialMedia => '\u{1F4F1}',
      };

  List<Color> get _gradientColors => switch (widget.expertType) {
        ExpertChatType.fitness => const [Color(0xFF00B894), Color(0xFF55EFC4)],
        ExpertChatType.socialMedia => const [Color(0xFF0984E3), Color(0xFF74B9FF)],
      };

  Color get _accentColor => switch (widget.expertType) {
        ExpertChatType.fitness => AppPalette.success,
        ExpertChatType.socialMedia => const Color(0xFF0984E3),
      };

  String get _inputHint => switch (widget.expertType) {
        ExpertChatType.fitness => 'Ask your fitness coach...',
        ExpertChatType.socialMedia => 'Ask your social media expert...',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(theme, colors),

            // Chat content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User message (placeholder)
                  _buildUserMessage(_placeholderUserMessage),
                  const SizedBox(height: 14),

                  // AI structured response
                  _buildAiResponse(theme, colors),
                  const SizedBox(height: 12),

                  // Cross-expert referral
                  _buildCrossReferral(theme, colors),
                ],
              ),
            ),

            // Input bar
            _buildInputBar(theme, colors),
          ],
        ),
      ),
    );
  }

  String get _placeholderUserMessage => switch (widget.expertType) {
        ExpertChatType.fitness =>
          'Give me a 20-minute HIIT workout for beginners',
        ExpertChatType.socialMedia =>
          'Write an Instagram caption for a productivity tip',
      };

  // -----------------------------------------------------------------------
  // Header
  // -----------------------------------------------------------------------
  Widget _buildHeader(ThemeData theme, AppColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              // TODO: wire to controller — go back to experts grid
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
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _gradientColors),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(_expertEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          // Name + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _expertName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        fontSize: 11,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // User message bubble
  // -----------------------------------------------------------------------
  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppPalette.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // AI structured response
  // -----------------------------------------------------------------------
  Widget _buildAiResponse(ThemeData theme, AppColors colors) {
    return switch (widget.expertType) {
      ExpertChatType.fitness => _buildFitnessCard(theme, colors),
      ExpertChatType.socialMedia => _buildSocialMediaCard(theme, colors),
    };
  }

  // -- Fitness workout table card --
  Widget _buildFitnessCard(ThemeData theme, AppColors colors) {
    const exercises = [
      ('Jumping Jacks', '30s', '15s'),
      ('Bodyweight Squats', '30s', '15s'),
      ('Push-up (Knees)', '30s', '15s'),
      ('Mountain Climbers', '30s', '15s'),
      ('Lunges', '30s', '15s'),
      ('High Knees', '30s', '15s'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mediumBorder,
        border: Border.all(
          color: AppPalette.success.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: colors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '20-Min Beginner HIIT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: ['Beginner', '20 min', '~200 cal'].map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Exercise table
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'EXERCISE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'DURATION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'REST',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ...exercises.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: colors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            e.$1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e.$3,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                // Repeat badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Repeat 2x (2 rounds total)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  children: [
                    _ActionBtn(
                      label: 'Save',
                      color: AppPalette.success,
                      textColor: Colors.white,
                      onTap: () {
                        // TODO: wire to controller
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      label: 'Share',
                      color: theme.scaffoldBackgroundColor,
                      textColor: theme.colorScheme.onSurface,
                      onTap: () {
                        // TODO: wire to controller
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      label: 'Modify',
                      color: theme.scaffoldBackgroundColor,
                      textColor: theme.colorScheme.onSurface,
                      onTap: () {
                        // TODO: wire to controller
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- Social media Instagram post card --
  Widget _buildSocialMediaCard(ThemeData theme, AppColors colors) {
    const hashtags = [
      ('#Productivity', Color(0xFF0984E3)),
      ('#EnergyManagement', Color(0xFF00B894)),
      ('#WorkSmart', Color(0xFF6C5CE7)),
      ('#DeepWork', Color(0xFFE17055)),
      ('#MindsetShift', Color(0xFFE17055)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mediumBorder,
        border: Border.all(
          color: const Color(0xFF0984E3).withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: colors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0984E3), Color(0xFF74B9FF)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Instagram Post',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stop managing your time. Start managing your energy. \u26A1\n\n'
                  'The most productive people don\'t work more hours - they align their hardest tasks with their peak energy windows.\n\n'
                  'Here\'s the shift: Track your energy for 3 days. Notice when you feel sharpest. Schedule deep work ONLY during those hours.\n\n'
                  'Everything else? Automate, delegate, or batch it. \u{1F680}',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 14),
                // Hashtags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: hashtags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tag.$2.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag.$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tag.$2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                // Best time
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Best time to post: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                      const Text(
                        'Tuesday 10 AM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Action buttons
                Row(
                  children: [
                    _ActionBtn(
                      label: 'Copy Caption',
                      color: const Color(0xFF0984E3),
                      textColor: Colors.white,
                      onTap: () {
                        // TODO: wire to controller
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      label: 'Copy Tags',
                      color: theme.scaffoldBackgroundColor,
                      textColor: theme.colorScheme.onSurface,
                      onTap: () {
                        // TODO: wire to controller
                      },
                    ),
                    const SizedBox(width: 8),
                    _ActionBtn(
                      label: 'Save',
                      color: theme.scaffoldBackgroundColor,
                      textColor: theme.colorScheme.onSurface,
                      onTap: () {
                        // TODO: wire to controller
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Cross-expert referral banner
  // -----------------------------------------------------------------------
  Widget _buildCrossReferral(ThemeData theme, AppColors colors) {
    final (emoji, text, boldText) = switch (widget.expertType) {
      ExpertChatType.fitness => (
          '\u{1F953}',
          'Want a post-workout meal? ',
          'Ask the Expert Chef',
        ),
      ExpertChatType.socialMedia => (
          '\u{1F4AA}',
          'Need a fitness routine? ',
          'Ask the Fitness Coach',
        ),
    };

    return GestureDetector(
      onTap: () {
        // TODO: wire to controller — navigate to linked expert or show paywall
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppPalette.error.withValues(alpha: 0.08),
          border: Border.all(
            color: AppPalette.error.withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: text),
                    TextSpan(
                      text: boldText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppPalette.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppPalette.error,
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Input bar
  // -----------------------------------------------------------------------
  Widget _buildInputBar(ThemeData theme, AppColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: _inputHint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: colors.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: colors.border, width: 1.5),
                  ),
                ),
                // TODO: wire to controller — send message
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // TODO: wire to controller — send message
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small action button used in structured cards
// ---------------------------------------------------------------------------
class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
