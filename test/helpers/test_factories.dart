/// Shared test data factories for AI Master.
///
/// Every factory has sensible defaults so tests can call
/// `TestFactories.createSummary()` with zero arguments for a valid instance,
/// or override specific fields as needed.
library;

import 'package:ai_master/models/card_template_model.dart';
import 'package:ai_master/models/expert_model.dart';
import 'package:ai_master/models/referral_model.dart';
import 'package:ai_master/models/streak_model.dart';
import 'package:ai_master/models/subscription_model.dart';
import 'package:ai_master/models/summary_model.dart';
import 'package:ai_master/models/usage_model.dart';
import 'package:ai_master/models/user_model.dart';

/// Central factory for creating test model instances with configurable defaults.
class TestFactories {
  TestFactories._(); // Prevent instantiation.

  // ===========================================================================
  // Fixed dates for deterministic tests
  // ===========================================================================

  /// A fixed reference date to avoid flaky time-dependent tests.
  static final DateTime referenceDate = DateTime(2026, 5, 14, 10, 30, 0);

  /// Yesterday relative to [referenceDate].
  static final DateTime yesterday = DateTime(2026, 5, 13, 10, 30, 0);

  /// Tomorrow relative to [referenceDate].
  static final DateTime tomorrow = DateTime(2026, 5, 15, 10, 30, 0);

  /// A date 7 days from [referenceDate] (useful for trial end).
  static final DateTime oneWeekLater = DateTime(2026, 5, 21, 10, 30, 0);

  /// A date 30 days from [referenceDate].
  static final DateTime oneMonthLater = DateTime(2026, 6, 13, 10, 30, 0);

  /// A date in the past (trial expired).
  static final DateTime pastDate = DateTime(2026, 4, 1, 10, 30, 0);

  // ===========================================================================
  // SummaryModel
  // ===========================================================================

  static SummaryModel createSummary({
    String? id,
    String? title,
    String? sourceUrl,
    SummarySourceType? sourceType,
    String? originalContent,
    List<String>? bulletPoints,
    String? paragraphSummary,
    List<String>? keyTakeaways,
    List<String>? actionItems,
    int? wordCount,
    DateTime? createdAt,
    bool? isFavorite,
    List<String>? tags,
    String? sourceName,
  }) {
    return SummaryModel(
      id: id ?? 'test-summary-1',
      title: title ?? 'How AI Is Transforming Healthcare',
      sourceUrl: sourceUrl ?? 'https://example.com/ai-healthcare',
      sourceType: sourceType ?? SummarySourceType.url,
      originalContent: originalContent ??
          'Artificial intelligence is rapidly transforming healthcare '
              'delivery across the globe. From diagnostic imaging to drug '
              'discovery, AI systems are augmenting clinician capabilities '
              'and improving patient outcomes.',
      bulletPoints: bulletPoints ??
          const [
            'AI is being used in diagnostic imaging to detect diseases earlier',
            'Drug discovery timelines are being shortened by machine learning',
            'Patient outcomes improve when AI augments clinical decisions',
            'Healthcare costs could decrease by 30% with AI adoption',
          ],
      paragraphSummary: paragraphSummary ??
          'Artificial intelligence is rapidly transforming healthcare delivery '
              'across the globe, from diagnostic imaging to drug discovery. AI '
              'systems are augmenting clinician capabilities and improving '
              'patient outcomes while potentially reducing costs by up to 30%.',
      keyTakeaways: keyTakeaways ??
          const [
            'AI diagnostics catch diseases earlier than traditional methods',
            'Machine learning accelerates drug discovery pipelines',
            'Cost savings of up to 30% are projected industry-wide',
          ],
      actionItems: actionItems ??
          const [
            'Research AI-powered diagnostic tools for your practice',
            'Evaluate ML-based drug discovery partnerships',
            'Assess potential cost savings in your organization',
          ],
      wordCount: wordCount ?? 42,
      createdAt: createdAt ?? referenceDate,
      isFavorite: isFavorite ?? false,
      tags: tags ?? const ['ai', 'healthcare', 'technology'],
      sourceName: sourceName ?? 'Example News',
    );
  }

  /// Create a summary from plain text (no URL).
  static SummaryModel createTextSummary({
    String? id,
    String? title,
    DateTime? createdAt,
  }) {
    return createSummary(
      id: id ?? 'test-text-summary',
      title: title ?? 'Pasted Text Summary',
      sourceUrl: null,
      sourceType: SummarySourceType.text,
      sourceName: null,
      createdAt: createdAt,
    );
  }

  /// Create a summary from a PDF.
  static SummaryModel createPdfSummary({
    String? id,
    String? title,
    DateTime? createdAt,
  }) {
    return createSummary(
      id: id ?? 'test-pdf-summary',
      title: title ?? 'Research Paper Summary',
      sourceUrl: null,
      sourceType: SummarySourceType.pdf,
      sourceName: 'research_paper.pdf',
      createdAt: createdAt,
    );
  }

  /// Create a list of summaries for library tests.
  static List<SummaryModel> createSummaryList({int count = 5}) {
    return List.generate(count, (i) {
      final types = SummarySourceType.values;
      return createSummary(
        id: 'test-summary-$i',
        title: 'Test Summary #$i',
        sourceType: types[i % types.length],
        createdAt: referenceDate.subtract(Duration(hours: i)),
        isFavorite: i % 3 == 0,
      );
    });
  }

  // ===========================================================================
  // UserModel
  // ===========================================================================

  static UserModel createUser({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserTier? tier,
    DateTime? trialEndsAt,
    int? streakCount,
    String? referralCode,
    DateTime? createdAt,
    bool? isAnonymous,
  }) {
    return UserModel(
      uid: uid ?? 'test-user-uid-123',
      email: email ?? 'test@example.com',
      displayName: displayName ?? 'Test User',
      photoUrl: photoUrl,
      tier: tier ?? UserTier.free,
      trialEndsAt: trialEndsAt,
      streakCount: streakCount ?? 5,
      referralCode: referralCode ?? 'REF-TEST-ABC',
      createdAt: createdAt ?? referenceDate,
      isAnonymous: isAnonymous ?? false,
    );
  }

  /// Create an anonymous user (onboarding state).
  static UserModel createAnonymousUser({String? uid}) {
    return createUser(
      uid: uid ?? 'anon-uid-456',
      email: null,
      displayName: null,
      photoUrl: null,
      isAnonymous: true,
    );
  }

  /// Create a pro-tier user.
  static UserModel createProUser({String? uid, String? email}) {
    return createUser(
      uid: uid ?? 'pro-user-uid-789',
      email: email ?? 'pro@example.com',
      displayName: 'Pro User',
      tier: UserTier.pro,
    );
  }

  // ===========================================================================
  // UsageModel
  // ===========================================================================

  static UsageModel createUsage({
    int? summariesUsed,
    int? tokensUsed,
    int? expertQueriesUsed,
    DateTime? lastResetDate,
    int? dailyLimit,
    int? tokenLimit,
  }) {
    return UsageModel(
      summariesUsed: summariesUsed ?? 1,
      tokensUsed: tokensUsed ?? 2500,
      expertQueriesUsed: expertQueriesUsed ?? 0,
      lastResetDate: lastResetDate ?? referenceDate,
      dailyLimit: dailyLimit ?? 3,
      tokenLimit: tokenLimit ?? 5000,
    );
  }

  /// Create usage at the daily limit (free tier exhausted).
  static UsageModel createExhaustedUsage() {
    return createUsage(
      summariesUsed: 3,
      tokensUsed: 4800,
      dailyLimit: 3,
      tokenLimit: 5000,
    );
  }

  /// Create fresh usage with nothing consumed.
  static UsageModel createFreshUsage({DateTime? lastResetDate}) {
    return createUsage(
      summariesUsed: 0,
      tokensUsed: 0,
      expertQueriesUsed: 0,
      lastResetDate: lastResetDate,
    );
  }

  // ===========================================================================
  // ExpertModel
  // ===========================================================================

  static ExpertModel createExpert({
    ExpertType? type,
    String? name,
    String? description,
    String? iconEmoji,
    List<int>? gradientColors,
    String? systemPrompt,
    bool? isLocked,
    bool? isComingSoon,
  }) {
    return ExpertModel(
      type: type ?? ExpertType.fitness,
      name: name ?? 'Fitness Coach',
      description: description ??
          'Workout plans, nutrition advice & progress tracking',
      iconEmoji: iconEmoji ?? '💪',
      gradientColors: gradientColors ?? const [0xFFEF4444, 0xFFF97316],
      systemPrompt: systemPrompt ?? 'You are an expert Fitness Coach.',
      isLocked: isLocked ?? false,
      isComingSoon: isComingSoon ?? false,
    );
  }

  /// Create a locked expert (premium only).
  static ExpertModel createLockedExpert({ExpertType? type}) {
    return createExpert(
      type: type ?? ExpertType.salesCoach,
      name: 'Sales Coach',
      description: 'Sales scripts, objection handling & negotiation',
      iconEmoji: '💼',
      gradientColors: const [0xFF3B82F6, 0xFF6366F1],
      isLocked: true,
    );
  }

  /// Create the full list of 6 experts.
  static List<ExpertModel> createExpertList({
    bool allUnlocked = false,
  }) {
    final freeTypes = {
      ExpertType.socialMedia,
      ExpertType.fitness,
      ExpertType.writingAssistant,
    };
    return ExpertType.values.map((type) {
      return createExpert(
        type: type,
        name: _expertName(type),
        isLocked: allUnlocked ? false : !freeTypes.contains(type),
      );
    }).toList();
  }

  static String _expertName(ExpertType type) {
    switch (type) {
      case ExpertType.socialMedia:
        return 'Social Media Expert';
      case ExpertType.fitness:
        return 'Fitness Coach';
      case ExpertType.chef:
        return 'Expert Chef';
      case ExpertType.homeAdvisor:
        return 'Home Advisor';
      case ExpertType.salesCoach:
        return 'Sales Coach';
      case ExpertType.writingAssistant:
        return 'Writing Assistant';
    }
  }

  // ===========================================================================
  // ExpertMessage
  // ===========================================================================

  static ExpertMessage createUserMessage({
    String? id,
    String? content,
    DateTime? timestamp,
  }) {
    return ExpertMessage(
      id: id ?? 'msg-user-1',
      role: MessageRole.user,
      content: content ?? 'Give me a 30-minute workout plan',
      timestamp: timestamp ?? referenceDate,
    );
  }

  static ExpertMessage createAssistantMessage({
    String? id,
    String? content,
    Map<String, dynamic>? structuredOutput,
    DateTime? timestamp,
  }) {
    return ExpertMessage(
      id: id ?? 'msg-assistant-1',
      role: MessageRole.assistant,
      content: content ??
          'Here is your 30-minute workout plan:\n'
              '1. Warm-up: 5 min light jog\n'
              '2. Squats: 3x12\n'
              '3. Push-ups: 3x15\n'
              '4. Plank: 3x30s\n'
              '5. Cool-down: 5 min stretching',
      structuredOutput: structuredOutput,
      timestamp: timestamp ?? referenceDate.add(const Duration(seconds: 30)),
    );
  }

  // ===========================================================================
  // ExpertConversation
  // ===========================================================================

  static ExpertConversation createConversation({
    String? id,
    ExpertType? expertType,
    List<ExpertMessage>? messages,
    DateTime? createdAt,
  }) {
    return ExpertConversation(
      id: id ?? 'conv-1',
      expertType: expertType ?? ExpertType.fitness,
      messages: messages ??
          [
            createUserMessage(),
            createAssistantMessage(),
          ],
      createdAt: createdAt ?? referenceDate,
    );
  }

  // ===========================================================================
  // SubscriptionModel
  // ===========================================================================

  static SubscriptionModel createSubscription({
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    PlanType? planType,
    DateTime? expiresAt,
    DateTime? trialEndsAt,
  }) {
    return SubscriptionModel(
      tier: tier ?? SubscriptionTier.free,
      status: status ?? SubscriptionStatus.expired,
      planType: planType,
      expiresAt: expiresAt,
      trialEndsAt: trialEndsAt,
    );
  }

  /// Create a free-tier subscription (default state).
  static SubscriptionModel createFreeSubscription() {
    return const SubscriptionModel(
      tier: SubscriptionTier.free,
      status: SubscriptionStatus.expired,
    );
  }

  /// Create an active Pro subscription.
  static SubscriptionModel createProSubscription({
    PlanType? planType,
    DateTime? expiresAt,
  }) {
    return SubscriptionModel(
      tier: SubscriptionTier.pro,
      status: SubscriptionStatus.active,
      planType: planType ?? PlanType.monthly,
      expiresAt: expiresAt ?? oneMonthLater,
    );
  }

  /// Create a trial subscription (active).
  static SubscriptionModel createTrialSubscription({
    DateTime? trialEndsAt,
  }) {
    return SubscriptionModel(
      tier: SubscriptionTier.pro,
      status: SubscriptionStatus.trial,
      trialEndsAt: trialEndsAt ?? oneWeekLater,
      expiresAt: trialEndsAt ?? oneWeekLater,
    );
  }

  /// Create an expired trial subscription.
  static SubscriptionModel createExpiredTrialSubscription() {
    return SubscriptionModel(
      tier: SubscriptionTier.pro,
      status: SubscriptionStatus.trial,
      trialEndsAt: pastDate,
      expiresAt: pastDate,
    );
  }

  /// Create a cancelled subscription.
  static SubscriptionModel createCancelledSubscription() {
    return SubscriptionModel(
      tier: SubscriptionTier.pro,
      status: SubscriptionStatus.cancelled,
      expiresAt: oneWeekLater, // Access until end of period.
    );
  }

  // ===========================================================================
  // StreakModel
  // ===========================================================================

  static StreakModel createStreak({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSummaryDate,
    int? freezesRemaining,
    int? freezesUsedThisWeek,
    List<DateTime>? activeDays,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? 5,
      longestStreak: longestStreak ?? 12,
      lastSummaryDate: lastSummaryDate ?? referenceDate,
      freezesRemaining: freezesRemaining ?? 2,
      freezesUsedThisWeek: freezesUsedThisWeek ?? 0,
      activeDays: activeDays ??
          List.generate(
            5,
            (i) => referenceDate.subtract(Duration(days: i)),
          ),
    );
  }

  /// Create a fresh streak (new user, no activity).
  static StreakModel createEmptyStreak() {
    return const StreakModel();
  }

  /// Create a streak that is at risk (last summary was yesterday).
  static StreakModel createAtRiskStreak() {
    return createStreak(
      currentStreak: 10,
      lastSummaryDate: yesterday,
    );
  }

  /// Create a broken streak (last summary was 3+ days ago).
  static StreakModel createBrokenStreak() {
    return createStreak(
      currentStreak: 0,
      lastSummaryDate: referenceDate.subtract(const Duration(days: 3)),
      freezesRemaining: 0,
    );
  }

  // ===========================================================================
  // ReferralModel
  // ===========================================================================

  static ReferralModel createReferral({
    String? code,
    List<ReferredUser>? referredUsers,
    int? rewardsEarned,
    String? link,
  }) {
    return ReferralModel(
      code: code ?? 'REF-TEST-ABC',
      referredUsers: referredUsers ??
          [
            createReferredUser(
              displayName: 'Alice',
              status: ReferralStatus.joined,
            ),
            createReferredUser(
              displayName: 'Bob',
              status: ReferralStatus.pending,
            ),
          ],
      rewardsEarned: rewardsEarned ?? 1,
      link: link ?? 'https://aimaster.app/ref/REF-TEST-ABC',
    );
  }

  static ReferredUser createReferredUser({
    String? displayName,
    DateTime? joinedAt,
    ReferralStatus? status,
  }) {
    return ReferredUser(
      displayName: displayName ?? 'Friend User',
      joinedAt: joinedAt ?? referenceDate,
      status: status ?? ReferralStatus.pending,
    );
  }

  /// Create a referral with no referred users.
  static ReferralModel createEmptyReferral() {
    return createReferral(
      referredUsers: const [],
      rewardsEarned: 0,
    );
  }

  // ===========================================================================
  // CardTemplateModel
  // ===========================================================================

  static CardTemplateModel createCardTemplate({
    CardTemplate? template,
    CardAspectRatio? aspectRatio,
    List<int>? selectedPoints,
    bool? showWatermark,
    String? summaryId,
  }) {
    return CardTemplateModel(
      template: template ?? CardTemplate.light,
      aspectRatio: aspectRatio ?? CardAspectRatio.square,
      selectedPoints: selectedPoints ?? const [0, 1, 2],
      showWatermark: showWatermark ?? true,
      summaryId: summaryId ?? 'test-summary-1',
    );
  }

  // ===========================================================================
  // JSON Helpers (for testing fromJson paths)
  // ===========================================================================

  /// Complete valid JSON for SummaryModel.
  static Map<String, dynamic> createSummaryJson({
    String? id,
    String? title,
    String? sourceType,
    String? createdAt,
  }) {
    return {
      'id': id ?? 'test-summary-1',
      'title': title ?? 'How AI Is Transforming Healthcare',
      'sourceUrl': 'https://example.com/ai-healthcare',
      'sourceType': sourceType ?? 'url',
      'originalContent': 'AI is rapidly transforming healthcare.',
      'bulletPoints': ['Point 1', 'Point 2', 'Point 3'],
      'paragraphSummary': 'AI is transforming healthcare globally.',
      'keyTakeaways': ['Takeaway 1', 'Takeaway 2'],
      'actionItems': ['Action 1', 'Action 2'],
      'wordCount': 42,
      'createdAt': createdAt ?? referenceDate.toIso8601String(),
      'isFavorite': false,
      'tags': ['ai', 'healthcare'],
      'sourceName': 'Example News',
    };
  }

  /// JSON with missing optional fields (tests fallback defaults).
  static Map<String, dynamic> createMinimalSummaryJson() {
    return {
      'id': 'minimal-1',
      'title': 'Minimal Summary',
      'sourceType': 'text',
      'originalContent': 'Some content.',
      'bulletPoints': <String>[],
      'paragraphSummary': 'Some content.',
      'keyTakeaways': <String>[],
      'actionItems': <String>[],
      'wordCount': 2,
      'createdAt': referenceDate.toIso8601String(),
    };
  }

  /// Complete valid JSON for UserModel.
  static Map<String, dynamic> createUserJson({
    String? uid,
    String? email,
    String? tier,
    bool? isAnonymous,
  }) {
    return {
      'uid': uid ?? 'test-user-uid-123',
      'email': email ?? 'test@example.com',
      'displayName': 'Test User',
      'photoUrl': null,
      'tier': tier ?? 'free',
      'trialEndsAt': null,
      'streakCount': 5,
      'referralCode': 'REF-TEST-ABC',
      'createdAt': referenceDate.toIso8601String(),
      'isAnonymous': isAnonymous ?? false,
    };
  }

  /// Complete valid JSON for UsageModel.
  static Map<String, dynamic> createUsageJson({
    int? summariesUsed,
    int? dailyLimit,
  }) {
    return {
      'summariesUsed': summariesUsed ?? 1,
      'tokensUsed': 2500,
      'expertQueriesUsed': 0,
      'lastResetDate': referenceDate.toIso8601String(),
      'dailyLimit': dailyLimit ?? 3,
      'tokenLimit': 5000,
    };
  }

  /// Complete valid JSON for ExpertModel.
  static Map<String, dynamic> createExpertJson({
    String? type,
    bool? isLocked,
  }) {
    return {
      'type': type ?? 'fitness',
      'name': 'Fitness Coach',
      'description': 'Workout plans, nutrition advice & progress tracking',
      'iconEmoji': '💪',
      'gradientColors': [0xFFEF4444, 0xFFF97316],
      'systemPrompt': 'You are an expert Fitness Coach.',
      'isLocked': isLocked ?? false,
      'isComingSoon': false,
    };
  }

  /// Complete valid JSON for ExpertMessage.
  static Map<String, dynamic> createExpertMessageJson({
    String? role,
    String? content,
  }) {
    return {
      'id': 'msg-1',
      'role': role ?? 'user',
      'content': content ?? 'Hello, coach!',
      'structuredOutput': null,
      'timestamp': referenceDate.toIso8601String(),
    };
  }

  /// Complete valid JSON for SubscriptionModel.
  static Map<String, dynamic> createSubscriptionJson({
    String? tier,
    String? status,
    String? planType,
  }) {
    return {
      'tier': tier ?? 'free',
      'status': status ?? 'expired',
      'planType': planType,
      'expiresAt': null,
      'trialEndsAt': null,
    };
  }

  /// Complete valid JSON for StreakModel.
  static Map<String, dynamic> createStreakJson({
    int? currentStreak,
    String? lastSummaryDate,
  }) {
    return {
      'currentStreak': currentStreak ?? 5,
      'longestStreak': 12,
      'lastSummaryDate': lastSummaryDate ?? referenceDate.toIso8601String(),
      'freezesRemaining': 2,
      'freezesUsedThisWeek': 0,
      'activeDays': List.generate(
        5,
        (i) => referenceDate
            .subtract(Duration(days: i))
            .toIso8601String(),
      ),
    };
  }

  /// Complete valid JSON for ReferralModel.
  static Map<String, dynamic> createReferralJson() {
    return {
      'code': 'REF-TEST-ABC',
      'referredUsers': [
        {
          'displayName': 'Alice',
          'joinedAt': referenceDate.toIso8601String(),
          'status': 'joined',
        },
        {
          'displayName': 'Bob',
          'joinedAt': null,
          'status': 'pending',
        },
      ],
      'rewardsEarned': 1,
      'link': 'https://aimaster.app/ref/REF-TEST-ABC',
    };
  }

  /// Complete valid JSON for CardTemplateModel.
  static Map<String, dynamic> createCardTemplateJson() {
    return {
      'template': 'light',
      'aspectRatio': 'square',
      'selectedPoints': [0, 1, 2],
      'showWatermark': true,
      'summaryId': 'test-summary-1',
    };
  }

  /// RevenueCat customer info JSON for a pro subscriber.
  static Map<String, dynamic> createCustomerInfoJson({
    bool isActive = true,
    String periodType = 'NORMAL',
    String? expirationDate,
  }) {
    return {
      'entitlements': {
        'pro': {
          'isActive': isActive,
          'periodType': periodType,
          'expirationDate':
              expirationDate ?? oneMonthLater.toIso8601String(),
        },
      },
    };
  }

  /// RevenueCat customer info JSON for a free (no entitlement) user.
  static Map<String, dynamic> createFreeCustomerInfoJson() {
    return {
      'entitlements': <String, dynamic>{},
    };
  }
}
