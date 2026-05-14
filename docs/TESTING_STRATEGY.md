# Testing Strategy - AI Master: Summary & Assistant

> Comprehensive testing plan covering unit, widget, integration, and E2E tests.
> Last updated: 2026-05-14

---

## Table of Contents

1. [Test Pyramid](#1-test-pyramid)
2. [Unit Tests: Models](#2-unit-tests-models)
3. [Unit Tests: Services](#3-unit-tests-services)
4. [Controller Tests](#4-controller-tests)
5. [Widget Tests](#5-widget-tests)
6. [Integration Tests](#6-integration-tests)
7. [E2E Tests (Manual)](#7-e2e-tests-manual)
8. [Test Coverage Targets](#8-test-coverage-targets)
9. [Test Data Factory](#9-test-data-factory)
10. [Test Infrastructure](#10-test-infrastructure)

---

## 1. Test Pyramid

```
                 /   E2E Tests   \            5 critical flows (manual, real device)
                / Integration     \          10 cross-layer user flows
               / Widget Tests      \         20 screen/widget tests
              / Controller Tests    \         6 controller test files (~60 tests)
             / Service Unit Tests    \        8 service test files (~100 tests)
            /  Model Unit Tests       \       8 model test files (~120 tests)
```

**Total estimated test count: ~315 tests**

| Layer             | Files | Est. Tests | Execution   |
|-------------------|-------|------------|-------------|
| Model Unit        | 8     | ~120       | `flutter test test/models/`       |
| Service Unit      | 8     | ~100       | `flutter test test/services/`     |
| Controller        | 6     | ~60        | `flutter test test/controllers/`  |
| Widget            | 20    | ~80        | `flutter test test/screens/`      |
| Integration       | 10    | ~40        | `flutter test integration_test/`  |
| E2E (manual)      | 5     | ~25 steps  | Manual on physical device         |

---

## 2. Unit Tests: Models

Each model test file validates: constructor defaults, `fromJson` (happy path + missing/null fields + malformed data), `toJson` round-trip, `copyWith` (each field individually + multiple fields), `Equatable` equality/inequality, and computed getters.

### 2.1 `test/models/summary_model_test.dart` -- ~18 tests

| # | Test Case |
|---|-----------|
| 1 | Constructor creates instance with all required fields |
| 2 | Constructor applies defaults for optional fields (isFavorite=false, tags=[]) |
| 3 | fromJson parses complete valid JSON |
| 4 | fromJson handles missing optional fields gracefully |
| 5 | fromJson handles null values with fallback defaults |
| 6 | fromJson parses createdAt ISO 8601 string correctly |
| 7 | fromJson falls back to SummarySourceType.text for unknown sourceType |
| 8 | toJson produces correct map structure |
| 9 | toJson -> fromJson round-trip preserves all data |
| 10 | copyWith overrides single field, preserves others |
| 11 | copyWith overrides multiple fields simultaneously |
| 12 | copyWith with no arguments returns equal object |
| 13 | Equatable: two identical instances are equal |
| 14 | Equatable: instances with different id are not equal |
| 15 | Equatable: instances with different isFavorite are not equal |
| 16 | SummarySourceType.fromJson maps 'text', 'url', 'pdf' correctly |
| 17 | SummarySourceType.fromJson returns text for unknown value |
| 18 | SummarySourceType.toJson returns correct string |

### 2.2 `test/models/user_model_test.dart` -- ~15 tests

| # | Test Case |
|---|-----------|
| 1 | Constructor creates instance with required fields |
| 2 | Constructor defaults: tier=free, streakCount=0, isAnonymous=false |
| 3 | fromJson parses complete valid JSON |
| 4 | fromJson handles missing optional fields (email, displayName, photoUrl, trialEndsAt) |
| 5 | fromJson handles null uid gracefully (defaults to empty string) |
| 6 | fromJson parses trialEndsAt ISO 8601 string |
| 7 | toJson produces correct map including nullable fields |
| 8 | toJson -> fromJson round-trip preserves all data |
| 9 | copyWith overrides tier from free to pro |
| 10 | copyWith overrides isAnonymous flag |
| 11 | Equatable: identical instances are equal |
| 12 | Equatable: different uid makes them unequal |
| 13 | UserTier.fromJson maps 'free' and 'pro' correctly |
| 14 | UserTier.fromJson returns free for unknown value |
| 15 | UserTier.toJson returns correct string |

### 2.3 `test/models/usage_model_test.dart` -- ~14 tests

| # | Test Case |
|---|-----------|
| 1 | Constructor with defaults (summariesUsed=0, tokensUsed=0) |
| 2 | fromJson parses complete valid JSON |
| 3 | fromJson handles missing fields with defaults |
| 4 | fromJson parses lastResetDate correctly |
| 5 | toJson produces correct map |
| 6 | toJson -> fromJson round-trip |
| 7 | copyWith overrides single field |
| 8 | hasReachedDailyLimit returns true when summariesUsed >= dailyLimit |
| 9 | hasReachedDailyLimit returns false when summariesUsed < dailyLimit |
| 10 | hasReachedTokenLimit returns true when tokensUsed >= tokenLimit |
| 11 | hasReachedTokenLimit returns false when tokensUsed < tokenLimit |
| 12 | summariesRemaining returns correct count |
| 13 | summariesRemaining clamps to 0 when over limit |
| 14 | Equatable: identical instances are equal |

### 2.4 `test/models/expert_model_test.dart` -- ~20 tests

| # | Test Case |
|---|-----------|
| 1 | ExpertModel constructor with all required fields |
| 2 | ExpertModel defaults: isLocked=false, isComingSoon=false |
| 3 | ExpertModel.fromJson parses complete JSON |
| 4 | ExpertModel.fromJson handles missing fields |
| 5 | ExpertModel.toJson produces correct map |
| 6 | ExpertModel toJson -> fromJson round-trip |
| 7 | ExpertModel copyWith overrides individual fields |
| 8 | ExpertModel Equatable equality |
| 9 | ExpertType.fromJson maps all 6 types correctly |
| 10 | ExpertType.fromJson returns writingAssistant for unknown value |
| 11 | MessageRole.fromJson maps 'user' and 'assistant' |
| 12 | MessageRole.fromJson returns user for unknown value |
| 13 | ExpertMessage constructor with required fields |
| 14 | ExpertMessage.fromJson parses complete JSON including structuredOutput |
| 15 | ExpertMessage.fromJson handles null structuredOutput |
| 16 | ExpertMessage.toJson produces correct map |
| 17 | ExpertMessage copyWith overrides content |
| 18 | ExpertConversation constructor with defaults (empty messages) |
| 19 | ExpertConversation.fromJson parses nested messages array |
| 20 | ExpertConversation toJson -> fromJson round-trip with messages |

### 2.5 `test/models/subscription_model_test.dart` -- ~18 tests

| # | Test Case |
|---|-----------|
| 1 | Constructor defaults: tier=free, status=expired |
| 2 | fromJson parses complete valid JSON |
| 3 | fromJson handles missing planType (nullable) |
| 4 | fromJson handles missing expiresAt and trialEndsAt |
| 5 | toJson produces correct map with nullable fields |
| 6 | toJson -> fromJson round-trip |
| 7 | copyWith overrides tier |
| 8 | isTrialActive returns true when status=trial and trialEndsAt is future |
| 9 | isTrialActive returns false when status=trial and trialEndsAt is past |
| 10 | isTrialActive returns false when status is not trial |
| 11 | daysLeftInTrial returns positive days when trial is active |
| 12 | daysLeftInTrial returns 0 when trial is inactive |
| 13 | hasProAccess returns true for pro+active |
| 14 | hasProAccess returns true for pro+trial (active) |
| 15 | hasProAccess returns false for free tier |
| 16 | hasProAccess returns false for pro+expired |
| 17 | SubscriptionTier.fromJson maps correctly, defaults to free |
| 18 | SubscriptionStatus.fromJson and PlanType.fromJson map correctly |

### 2.6 `test/models/streak_model_test.dart` -- ~14 tests

| # | Test Case |
|---|-----------|
| 1 | Constructor defaults: currentStreak=0, longestStreak=0, etc. |
| 2 | fromJson parses complete JSON |
| 3 | fromJson handles missing lastSummaryDate (nullable) |
| 4 | fromJson parses activeDays list of ISO 8601 strings |
| 5 | toJson produces correct map |
| 6 | toJson -> fromJson round-trip |
| 7 | copyWith overrides currentStreak |
| 8 | isAtRisk returns true when lastSummaryDate was yesterday |
| 9 | isAtRisk returns false when lastSummaryDate is today |
| 10 | isAtRisk returns false when lastSummaryDate is null |
| 11 | isAtRisk returns false when lastSummaryDate was 2+ days ago |
| 12 | Equatable: identical instances are equal |
| 13 | Equatable: different currentStreak makes unequal |
| 14 | activeDays empty list default works |

### 2.7 `test/models/referral_model_test.dart` -- ~14 tests

| # | Test Case |
|---|-----------|
| 1 | ReferredUser constructor with required fields |
| 2 | ReferredUser defaults: status=pending |
| 3 | ReferredUser.fromJson parses complete JSON |
| 4 | ReferredUser.toJson produces correct map |
| 5 | ReferredUser copyWith overrides status |
| 6 | ReferralStatus.fromJson maps 'pending' and 'joined' |
| 7 | ReferralModel constructor with required fields |
| 8 | ReferralModel defaults: referredUsers=[], rewardsEarned=0 |
| 9 | ReferralModel.fromJson parses nested referredUsers list |
| 10 | ReferralModel.toJson produces correct map with nested objects |
| 11 | ReferralModel toJson -> fromJson round-trip |
| 12 | successfulReferrals counts only joined users |
| 13 | successfulReferrals returns 0 when all pending |
| 14 | ReferralModel Equatable equality |

### 2.8 `test/models/card_template_model_test.dart` -- ~12 tests

| # | Test Case |
|---|-----------|
| 1 | Constructor defaults: template=light, aspectRatio=square, showWatermark=true |
| 2 | fromJson parses complete JSON |
| 3 | fromJson handles missing fields with defaults |
| 4 | toJson produces correct map |
| 5 | toJson -> fromJson round-trip |
| 6 | copyWith overrides template |
| 7 | copyWith overrides aspectRatio |
| 8 | copyWith overrides selectedPoints |
| 9 | CardTemplate.fromJson maps all 4 values correctly |
| 10 | CardTemplate.fromJson defaults to light for unknown |
| 11 | CardAspectRatio.fromJson maps story/square/wide correctly |
| 12 | Equatable: identical instances are equal |

---

## 3. Unit Tests: Services

All service tests use mock implementations of abstract interfaces (see `test/helpers/mock_services.dart`). HTTP-dependent services use a mock Dio adapter.

### 3.1 `test/services/auth_service_test.dart` -- ~16 tests

| # | Test Case |
|---|-----------|
| 1 | signInAnonymously returns UserModel on success |
| 2 | signInAnonymously throws AuthException on provider failure |
| 3 | signInWithEmail returns UserModel on valid credentials |
| 4 | signInWithEmail throws AuthException for empty email |
| 5 | signInWithEmail throws AuthException for invalid email format |
| 6 | signInWithEmail throws AuthException for short password (<6 chars) |
| 7 | signInWithEmail maps 'user-not-found' to invalid-credentials |
| 8 | signInWithEmail maps 'email-already-in-use' to correct error |
| 9 | signInWithEmail maps 'too-many-requests' to rate limit error |
| 10 | signInWithEmail maps network error to NetworkException |
| 11 | signUpWithEmail throws AuthException for empty display name |
| 12 | signUpWithEmail returns UserModel on success |
| 13 | signInWithGoogle returns UserModel on success |
| 14 | linkAnonymousToEmail returns updated UserModel |
| 15 | signOut completes without error |
| 16 | currentUser returns null when no user signed in |

### 3.2 `test/services/summarizer_service_test.dart` -- ~16 tests

| # | Test Case |
|---|-----------|
| 1 | summarizeText returns SummaryModel on successful response |
| 2 | summarizeText throws ContentTooShortException for empty text |
| 3 | summarizeText throws ContentTooShortException for text with < 3 words |
| 4 | summarizeUrl returns SummaryModel on success |
| 5 | summarizeUrl throws ContentTooShortException for empty URL |
| 6 | summarizePdf returns SummaryModel on success |
| 7 | summarizePdf throws PdfParsingException for empty bytes |
| 8 | summarizeTextStream yields chunks until [DONE] |
| 9 | summarizeTextStream handles SSE "data: " prefix correctly |
| 10 | summarizeUrlStream throws for empty URL |
| 11 | toBullets splits content into list, stripping markers |
| 12 | toBullets returns empty list for empty string |
| 13 | toParagraph merges lines into single paragraph |
| 14 | toTakeaways strips numbered markers |
| 15 | toActionItems strips checkbox markers |
| 16 | DioException mapping: timeout -> TimeoutException, connection -> NetworkException, 429 -> TokenBudgetExceededException |

### 3.3 `test/services/library_service_test.dart` -- ~12 tests

| # | Test Case |
|---|-----------|
| 1 | saveSummary calls storage.put with correct JSON |
| 2 | saveSummary throws StorageException on storage failure |
| 3 | deleteSummary calls storage.delete with correct id |
| 4 | deleteSummary throws StorageException on failure |
| 5 | toggleFavorite flips isFavorite from false to true |
| 6 | toggleFavorite flips isFavorite from true to false |
| 7 | toggleFavorite does nothing if summary not found |
| 8 | getAllSummaries returns sorted list (newest first) |
| 9 | searchSummaries returns matching results |
| 10 | searchSummaries returns all when query is empty |
| 11 | filterByType returns only matching source type |
| 12 | isLibraryFull returns true at limit, false below, false for unlimited tier |

### 3.4 `test/services/subscription_service_test.dart` -- ~12 tests

| # | Test Case |
|---|-----------|
| 1 | initialize calls provider.initialize and identify |
| 2 | initialize throws PurchaseException on failure |
| 3 | getSubscriptionStatus returns SubscriptionModel with pro+active |
| 4 | getSubscriptionStatus returns free+expired when no entitlement |
| 5 | getSubscriptionStatus returns pro+trial when periodType is TRIAL |
| 6 | isProUser returns true for active pro subscription |
| 7 | isProUser returns false for free tier |
| 8 | isTrialActive returns true during trial period |
| 9 | purchasePackage calls provider.purchase with correct package ID |
| 10 | purchasePackage throws PurchaseCancelledException on user cancel |
| 11 | purchasePackage throws PurchaseAlreadyActiveException on duplicate |
| 12 | restorePurchases calls provider.restorePurchases |

### 3.5 `test/services/expert_service_test.dart` -- ~12 tests

| # | Test Case |
|---|-----------|
| 1 | sendQuery returns ExpertMessage on success |
| 2 | sendQuery throws ContentTooShortException for empty message |
| 3 | sendQuery sends correct payload (expert, message, systemPrompt, history) |
| 4 | sendQueryStream yields chunks until [DONE] |
| 5 | sendQueryStream throws for empty message |
| 6 | getAvailableExperts returns all 6 experts for pro tier |
| 7 | getAvailableExperts marks chef/homeAdvisor/salesCoach as locked for free tier |
| 8 | getAvailableExperts marks socialMedia/fitness/writingAssistant as unlocked for free |
| 9 | getSystemPrompt returns correct prompt for each ExpertType |
| 10 | getSystemPrompt falls back to writingAssistant for unknown |
| 11 | DioException 429 maps to TokenBudgetExceededException |
| 12 | DioException connectionError maps to NetworkException |

### 3.6 `test/services/streak_service_test.dart` -- ~12 tests

| # | Test Case |
|---|-----------|
| 1 | getStreak returns default StreakModel when storage is empty |
| 2 | getStreak returns persisted StreakModel from storage |
| 3 | getStreak throws StorageException on storage failure |
| 4 | recordSummaryToday increments streak when last was yesterday |
| 5 | recordSummaryToday resets to 1 when streak is broken (>1 day gap) |
| 6 | recordSummaryToday is no-op if already recorded today |
| 7 | recordSummaryToday uses freeze when gap is 2 days and freeze available |
| 8 | recordSummaryToday sets longestStreak when new streak exceeds it |
| 9 | recordSummaryToday trims activeDays to last 14 days |
| 10 | useStreakFreeze decrements freezesRemaining |
| 11 | useStreakFreeze throws DailyLimitReachedException when no freezes left |
| 12 | shouldShowMilestone returns true for 7, 14, 30, 50, 100, 200, 365 |

### 3.7 `test/services/usage_service_test.dart` -- ~10 tests

| # | Test Case |
|---|-----------|
| 1 | getUsage returns cached data when same day |
| 2 | getUsage fetches from server when cache is stale (different day) |
| 3 | getUsage fetches from server when cache is empty |
| 4 | incrementSummaryCount posts to /usage/increment-summary |
| 5 | incrementSummaryCount updates cache with response |
| 6 | incrementTokenCount posts with correct token count |
| 7 | incrementTokenCount skips when tokens <= 0 |
| 8 | canSummarize returns true when under limits |
| 9 | canSummarize returns false when daily limit reached |
| 10 | remainingSummaries returns correct count for free tier |

### 3.8 `test/services/clipboard_service_test.dart` -- ~10 tests

| # | Test Case |
|---|-----------|
| 1 | getClipboardUrl returns URL when clipboard contains http:// URL |
| 2 | getClipboardUrl returns URL when clipboard contains https:// URL |
| 3 | getClipboardUrl returns URL for www. prefix |
| 4 | getClipboardUrl returns null when clipboard is empty |
| 5 | getClipboardUrl returns null when clipboard contains plain text |
| 6 | getClipboardText returns text when clipboard has >= 20 words |
| 7 | getClipboardText returns null when clipboard has < 20 words |
| 8 | getClipboardText returns null when clipboard contains a URL |
| 9 | getClipboardText returns null when clipboard is empty |
| 10 | isUrl correctly identifies URLs vs plain text |

---

## 4. Controller Tests

Controllers are tested using Riverpod's `ProviderContainer` with overridden service providers pointing to mock implementations.

### 4.1 `test/controllers/summarizer_controller_test.dart` -- ~10 tests

**State transitions to test:**

| # | Test Case | State Transition |
|---|-----------|-----------------|
| 1 | Initial build returns SummaryIdle | `_ -> idle` |
| 2 | summarizeText transitions idle -> loading -> streaming -> success | `idle -> loading -> streaming -> success` |
| 3 | summarizeText transitions idle -> loading -> error on service failure | `idle -> loading -> error` |
| 4 | summarizeUrl transitions idle -> loading -> streaming -> success | `idle -> loading -> streaming -> success` |
| 5 | summarizeUrl transitions idle -> loading -> error on network failure | `idle -> loading -> error` |
| 6 | summarizePdf transitions idle -> loading -> success | `idle -> loading -> success` |
| 7 | summarizePdf transitions idle -> loading -> error on empty PDF | `idle -> loading -> error` |
| 8 | switchFormat updates activeFormat on existing SummarySuccess | `success(bullets) -> success(paragraph)` |
| 9 | cancel stops streaming and returns to idle | `streaming -> idle` |
| 10 | reset returns to idle from any state | `* -> idle` |

### 4.2 `test/controllers/auth_controller_test.dart` -- ~10 tests

**State transitions to test:**

| # | Test Case | State Transition |
|---|-----------|-----------------|
| 1 | Initial build returns current user (or null) | `_ -> data(user)` or `_ -> data(null)` |
| 2 | signInAnonymously: null -> loading -> data(anonymous user) | `data(null) -> loading -> data(user{isAnonymous:true})` |
| 3 | signInAnonymously: error on provider failure | `data(null) -> loading -> error` |
| 4 | signInWithEmail: null -> loading -> data(user) | `data(null) -> loading -> data(user)` |
| 5 | signInWithEmail: error on invalid credentials | `data(null) -> loading -> error(AuthException)` |
| 6 | signUpWithEmail: null -> loading -> data(user) | `data(null) -> loading -> data(user)` |
| 7 | signInWithGoogle: null -> loading -> data(user) | `data(null) -> loading -> data(user)` |
| 8 | signOut: data(user) -> data(null) | `data(user) -> data(null)` |
| 9 | signOut: error on failure | `data(user) -> error` |
| 10 | authStateChanges stream updates controller state | `data(userA) -> data(userB)` via stream |

### 4.3 `test/controllers/home_controller_test.dart` -- ~10 tests

**State transitions to test:**

| # | Test Case | State Transition |
|---|-----------|-----------------|
| 1 | Initial build loads all data in parallel | `loading -> data(HomeState with all fields)` |
| 2 | Initial build returns minimal HomeState on error | `loading -> data(HomeState())` |
| 3 | checkClipboard updates clipboardUrl when URL found | `data(url:null) -> data(url:'https://...')` |
| 4 | checkClipboard updates clipboardText when long text found | `data(text:null) -> data(text:'long text...')` |
| 5 | checkClipboard silently ignores clipboard read failure | state unchanged |
| 6 | loadRecentSummaries updates recentSummaries (max 5) | `data(recent:[]) -> data(recent:[5 items])` |
| 7 | loadRecentSummaries preserves state on error | state unchanged |
| 8 | refresh reloads all data via build() | `data -> loading -> data` |
| 9 | Home state includes streak data | `data(streak.currentStreak == N)` |
| 10 | Home state includes usageRemaining | `data(usageRemaining == 3)` |

### 4.4 `test/controllers/library_controller_test.dart` -- ~12 tests

**State transitions to test:**

| # | Test Case | State Transition |
|---|-----------|-----------------|
| 1 | Initial build loads all summaries | `loading -> data(summaries:[...])` |
| 2 | Initial build returns empty LibraryState on error | `loading -> data(summaries:[])` |
| 3 | loadSummaries sets loading then loaded | `data(loading:false) -> data(loading:true) -> data(loading:false, summaries:[...])` |
| 4 | search updates summaries and searchQuery | `data -> data(loading:true) -> data(summaries:filtered, searchQuery:'query')` |
| 5 | search with empty query returns all summaries | `data -> data(summaries:all)` |
| 6 | filterByType(url) returns only URL summaries | `data -> data(summaries:urlOnly, activeFilter:url)` |
| 7 | filterByType(null) clears filter, returns all | `data(activeFilter:url) -> data(activeFilter:null, summaries:all)` |
| 8 | deleteSummary removes item optimistically | `data(summaries:[a,b,c]) -> data(summaries:[a,c])` |
| 9 | deleteSummary re-fetches on storage error | `data -> data(summaries:fresh from storage)` |
| 10 | toggleFavorite flips isFavorite optimistically | `data(summary.isFavorite:false) -> data(summary.isFavorite:true)` |
| 11 | toggleFavorite re-fetches on error | state reloaded from storage |
| 12 | search preserves activeFilter | `data(activeFilter:url, searchQuery:'') -> data(activeFilter:url, searchQuery:'query')` |

### 4.5 `test/controllers/subscription_controller_test.dart` -- ~10 tests

**State transitions to test:**

| # | Test Case | State Transition |
|---|-----------|-----------------|
| 1 | Initial build returns subscription status from service | `loading -> data(SubscriptionModel)` |
| 2 | Initial build defaults to free on error | `loading -> data(SubscriptionModel(free, expired))` |
| 3 | purchase(monthly) calls service and refreshes state | `data(free) -> data(pro, active)` |
| 4 | purchase cancelled keeps current state | `data(free) -> data(free)` (unchanged) |
| 5 | purchase error transitions to AsyncError | `data(free) -> error(PurchaseException)` |
| 6 | restore refreshes subscription status | `data(free) -> data(pro, active)` |
| 7 | restore error transitions to AsyncError | `data(free) -> error` |
| 8 | shouldShowPaywall returns true for free tier | true |
| 9 | shouldShowPaywall returns false for pro tier | false |
| 10 | paywallType returns correct type based on context flags | soft/hard/micro |

### 4.6 `test/controllers/expert_controller_test.dart` -- ~10 tests

**State transitions to test:**

| # | Test Case | State Transition |
|---|-----------|-----------------|
| 1 | Initial build returns empty ExpertChatState | `_ -> data(ExpertChatState())` |
| 2 | sendMessage adds user message, sets isStreaming=true | `data(messages:[]) -> data(messages:[user], isStreaming:true)` |
| 3 | sendMessage streams assistant response chunks | `data(isStreaming:true) -> data(messages:[user, partial], isStreaming:true)` |
| 4 | sendMessage completes with final assistant message | `data(isStreaming:true) -> data(messages:[user, assistant], isStreaming:false)` |
| 5 | sendMessage handles stream error gracefully | `data(isStreaming:true) -> data(isStreaming:false)` |
| 6 | sendMessage ignores empty text | state unchanged |
| 7 | selectExpert changes expert type and clears history | `data(expert:fitness, messages:[...]) -> data(expert:chef, messages:[])` |
| 8 | selectExpert cancels any active stream | streaming cancelled, new state |
| 9 | saveResponseToLibrary creates SummaryModel and saves | verify library.saveSummary called with correct data |
| 10 | saveResponseToLibrary throws on library error | throws AppException |

---

## 5. Widget Tests

For each screen, test: correct rendering with mock data, user interaction handling, loading/error/empty states, and navigation triggers.

### 5.1 `test/screens/splash/splash_screen_test.dart` -- ~3 tests

| # | Test Case |
|---|-----------|
| 1 | Renders app logo and loading indicator |
| 2 | Navigates to onboarding for unauthenticated user |
| 3 | Navigates to home for authenticated user |

### 5.2 `test/screens/onboarding/onboarding_screen_test.dart` -- ~5 tests

| # | Test Case |
|---|-----------|
| 1 | Renders all onboarding pages with correct content |
| 2 | Swipe advances to next page |
| 3 | Skip button navigates to home |
| 4 | Continue button on last page triggers sign-in |
| 5 | Page indicator reflects current page index |

### 5.3 `test/screens/home/home_screen_test.dart` -- ~6 tests

| # | Test Case |
|---|-----------|
| 1 | Renders with mock data (clipboard banner, recent summaries, streak) |
| 2 | Shows clipboard URL banner when URL detected |
| 3 | Hides clipboard banner when nothing detected |
| 4 | Tap on clipboard banner navigates to summary loading screen |
| 5 | Shows usage remaining count |
| 6 | Shows streak widget with correct day count |

### 5.4 `test/screens/home/home_screen_loading_test.dart` -- ~3 tests

| # | Test Case |
|---|-----------|
| 1 | Shows shimmer/skeleton loading state |
| 2 | Shows error state with retry button |
| 3 | Retry button triggers data reload |

### 5.5 `test/screens/library/library_screen_test.dart` -- ~6 tests

| # | Test Case |
|---|-----------|
| 1 | Renders list of summaries with title, source type, date |
| 2 | Search field filters displayed summaries |
| 3 | Source type filter chips are tappable and update list |
| 4 | Empty state shows illustration and CTA |
| 5 | Swipe to delete removes summary |
| 6 | Tap on summary navigates to summary result screen |

### 5.6 `test/screens/summary/summary_loading_screen_test.dart` -- ~4 tests

| # | Test Case |
|---|-----------|
| 1 | Shows loading animation during SummaryLoading state |
| 2 | Shows streaming text during SummaryStreaming state |
| 3 | Shows error message and retry during SummaryError state |
| 4 | Cancel button is visible and functional |

### 5.7 `test/screens/summary/summary_result_screen_test.dart` -- ~6 tests

| # | Test Case |
|---|-----------|
| 1 | Renders bullet points by default |
| 2 | Format switcher tabs are visible (Bullets, Paragraph, Takeaways, Actions) |
| 3 | Tapping Paragraph tab switches displayed content |
| 4 | Save to Library button triggers save action |
| 5 | Share button is visible |
| 6 | Shows word count and source info |

### 5.8 `test/screens/experts/experts_grid_screen_test.dart` -- ~5 tests

| # | Test Case |
|---|-----------|
| 1 | Renders grid of 6 expert cards |
| 2 | Locked experts show lock icon for free tier |
| 3 | All experts unlocked for pro tier |
| 4 | Tapping unlocked expert navigates to chat screen |
| 5 | Tapping locked expert triggers micro paywall |

### 5.9 `test/screens/experts/expert_chat_screen_test.dart` -- ~5 tests

| # | Test Case |
|---|-----------|
| 1 | Renders with empty state (welcome message from expert) |
| 2 | User can type and send message via input field |
| 3 | Shows user message bubble after sending |
| 4 | Shows streaming indicator during response |
| 5 | Shows assistant message bubble after response completes |

### 5.10 `test/screens/paywall/paywall_screen_test.dart` -- ~5 tests

| # | Test Case |
|---|-----------|
| 1 | Renders plan cards (Weekly, Monthly, Annual) |
| 2 | Default selected plan is highlighted |
| 3 | Tapping plan card selects it |
| 4 | Subscribe button triggers purchase flow |
| 5 | Restore Purchases button is visible and functional |

### 5.11 `test/screens/paywall/soft_paywall_sheet_test.dart` -- ~3 tests

| # | Test Case |
|---|-----------|
| 1 | Renders as bottom sheet with dismiss handle |
| 2 | Shows benefit list and CTA button |
| 3 | Dismiss gesture closes the sheet |

### 5.12 `test/screens/profile/profile_screen_test.dart` -- ~5 tests

| # | Test Case |
|---|-----------|
| 1 | Renders user info (name, email, avatar) |
| 2 | Shows current subscription tier badge |
| 3 | Shows summary stats (total summaries, streak) |
| 4 | Upgrade button visible for free tier |
| 5 | Sign out button triggers sign out flow |

### 5.13 `test/screens/main_shell_test.dart` -- ~4 tests

| # | Test Case |
|---|-----------|
| 1 | Renders bottom navigation bar with 4 tabs |
| 2 | Tapping Library tab shows library screen |
| 3 | Tapping Experts tab shows experts grid |
| 4 | Tapping Profile tab shows profile screen |

### 5.14-5.20 Additional Widget Tests -- ~25 tests across remaining widgets

| File | Tests | Scope |
|------|-------|-------|
| `test/widgets/common_widgets_test.dart` | 5 | Reusable widget components |
| `test/utils/summary_format_test.dart` | 4 | SummaryFormat enum labels |
| `test/utils/tier_limits_test.dart` | 6 | All TierLimits extension getters for free/pro |
| `test/utils/exceptions_test.dart` | 5 | Exception message formatting and toString |
| `test/router/app_router_test.dart` | 5 | Route definitions and guards |

---

## 6. Integration Tests

10 critical user flows that cross multiple layers (controller + service + model).

### Flow 1: Onboarding -> Home -> First Summary -> Result -> Library Save

```
Steps:
  1. App launches, user is unauthenticated
  2. Onboarding completes, auto anonymous sign-in
  3. Home screen loads with usage remaining = 3
  4. User pastes text, taps Summarize
  5. Loading -> Streaming -> Success with SummaryModel
  6. User taps "Save to Library"
  7. Library now contains 1 summary
  8. Navigate to Library tab, verify summary appears
```

**Mocks needed:** MockAuthProvider, MockLibraryStorage, mock Dio adapter

### Flow 2: Free User -> Hits Limit -> Paywall -> Trial Start -> Pro Unlocked

```
Steps:
  1. Sign in as free user
  2. Use 3 summaries (reaching daily limit)
  3. Attempt 4th summary -> DailyLimitReachedException
  4. Hard paywall shown (non-dismissible)
  5. User selects Monthly plan, purchase succeeds
  6. Subscription status updates to pro+active
  7. Attempt summary -> succeeds (unlimited)
  8. Library limit now unlimited
```

**Mocks needed:** MockUsageCache, MockPurchaseProvider, mock Dio adapter

### Flow 3: Paste URL -> Loading -> Streaming Result -> Format Switching

```
Steps:
  1. Clipboard contains "https://example.com/article"
  2. Home screen detects URL, shows banner
  3. User taps banner -> summarizeUrl triggered
  4. State: idle -> loading -> streaming (partial chunks) -> success
  5. Summary result shows bullet points by default
  6. User taps "Paragraph" -> content switches without network call
  7. User taps "Key Takeaways" -> content switches
  8. User taps "Action Items" -> content switches
```

**Mocks needed:** MockClipboardProvider, mock Dio adapter

### Flow 4: Library Search -> Filter -> Tap Item -> View Summary

```
Steps:
  1. Library contains 10 summaries (3 URL, 4 text, 3 PDF)
  2. User types search query -> results filtered
  3. User clears search -> all 10 shown
  4. User taps "URL" filter chip -> only 3 URL summaries shown
  5. User taps a summary -> navigates to detail view
  6. Summary detail shows all fields (title, bullets, paragraph, etc.)
```

**Mocks needed:** MockLibraryStorage pre-loaded with 10 summaries

### Flow 5: Expert Chat -> Send Query -> Streaming Response -> Save

```
Steps:
  1. User selects "Fitness Coach" expert
  2. ExpertChatState updates to expert: fitness, messages: []
  3. User types "Give me a 30-minute workout"
  4. User message appears in chat
  5. Streaming response arrives in chunks
  6. Final assistant message with structured content
  7. User taps "Save to Library"
  8. Library contains new summary with tags: ['expert', 'fitness']
```

**Mocks needed:** MockLibraryStorage, mock Dio adapter

### Flow 6: Referral -> Generate Link -> Share -> Friend Joins -> Reward

```
Steps:
  1. User opens referral section
  2. ReferralModel loaded with unique code and link
  3. User taps Share -> share sheet opens with link
  4. Simulate friend joining (update referredUsers list)
  5. successfulReferrals count increments
  6. rewardsEarned increments
```

**Mocks needed:** Mock referral service/storage

### Flow 7: Streak Tracking -> Day 1 -> Day 2 -> Milestone at Day 7

```
Steps:
  1. Day 1: User creates first summary
  2. recordSummaryToday -> streak = 1, lastSummaryDate = today
  3. Day 2: (mock next day) User creates summary
  4. recordSummaryToday -> streak = 2, lastSummaryDate = today
  5. Simulate days 3-6 (daily summaries)
  6. Day 7: recordSummaryToday -> streak = 7
  7. shouldShowMilestone(7) returns true
  8. Verify longestStreak updated to 7
```

**Mocks needed:** MockStreakStorage, controlled DateTime

### Flow 8: Card Creator -> Select Template -> Aspect Ratio -> Toggle Points -> Export

```
Steps:
  1. User has a saved summary with 5 bullet points
  2. Open card creator for that summary
  3. CardTemplateModel created with summaryId, default template=light
  4. User selects "dark" template -> copyWith(template: dark)
  5. User selects "story" aspect ratio -> copyWith(aspectRatio: story)
  6. User toggles bullet points 0, 2, 4 -> selectedPoints: [0, 2, 4]
  7. User toggles watermark off -> showWatermark: false
  8. Export triggered
```

**Mocks needed:** Pre-loaded summary in MockLibraryStorage

### Flow 9: Profile -> View Stats -> Upgrade -> Paywall -> Purchase

```
Steps:
  1. Profile screen loads with user info, free tier badge
  2. Summary count shows from LibraryService.getSummaryCount()
  3. Streak shows from StreakService.getStreak()
  4. User taps "Upgrade to Pro"
  5. Paywall screen shown
  6. User selects Annual plan, purchase succeeds
  7. Profile updates to show Pro badge
  8. Upgrade button hidden
```

**Mocks needed:** MockPurchaseProvider, MockLibraryStorage, MockStreakStorage

### Flow 10: Offline Mode -> Library Loads from Cache -> Error Banner -> Retry

```
Steps:
  1. Device goes offline (mock Dio to throw NetworkException)
  2. Library screen loads from local MockLibraryStorage (succeeds)
  3. Summaries display from cache
  4. Usage service fails -> graceful fallback
  5. Error banner shown "No internet connection"
  6. Device comes back online
  7. Retry button triggers refresh
  8. Fresh data loads from server
```

**Mocks needed:** MockLibraryStorage, configurable mock Dio (fail then succeed)

---

## 7. E2E Tests (Manual)

5 critical flows to test on a real physical device. These require human execution and visual verification.

### E2E 1: Full Signup -> Onboarding -> First Summary -> Paywall -> Subscribe

**Device:** Physical Android device (API 28+)
**Pre-conditions:** Fresh install, no prior data

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Install and launch app | Splash screen -> Onboarding |
| 2 | Complete onboarding (swipe through all pages) | Home screen loads |
| 3 | Verify anonymous sign-in happened | Profile shows anonymous user |
| 4 | Paste a URL in clipboard, return to app | Clipboard banner appears |
| 5 | Tap "Summarize" | Loading -> streaming -> result |
| 6 | Save to library | Success toast, library count = 1 |
| 7 | Create 2 more summaries | Usage counter decrements |
| 8 | Attempt 4th summary | Hard paywall appears |
| 9 | Select Monthly plan, complete purchase | Subscription active |
| 10 | Verify unlimited access | Summary succeeds, no paywall |

### E2E 2: Share Intent from Chrome -> Auto-Summarize -> Save

**Device:** Physical Android device
**Pre-conditions:** Signed-in user, Chrome browser installed

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Open article in Chrome | Article loads |
| 2 | Tap Share -> select AI Master | App opens with URL pre-filled |
| 3 | Observe auto-summarization | Loading -> streaming -> result |
| 4 | Save to library | Summary saved with sourceType=url |
| 5 | Open library, verify summary | Summary present with correct title |

### E2E 3: Offline Mode -> Library Accessible -> Online -> Sync

**Device:** Physical Android device
**Pre-conditions:** User has 5+ saved summaries

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Enable airplane mode | Device offline |
| 2 | Open app, navigate to Library | Cached summaries display |
| 3 | Search summaries | Local search works |
| 4 | Attempt new summary | Error: "No internet connection" |
| 5 | Disable airplane mode | Device online |
| 6 | Tap retry / pull to refresh | Fresh data loads |
| 7 | Create new summary | Works normally |

### E2E 4: Dark Mode -> Toggle -> All Screens Render Correctly

**Device:** Physical Android device
**Pre-conditions:** Signed-in user with data

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Set device to light mode | App renders in light theme |
| 2 | Navigate through all tabs | No rendering issues |
| 3 | Toggle device to dark mode | App switches to dark theme |
| 4 | Navigate: Home, Library, Experts, Profile | All screens render correctly |
| 5 | Open summary result screen | Text legible, contrast correct |
| 6 | Open expert chat | Message bubbles visible, correct colors |
| 7 | Open paywall | Plan cards visible, CTA buttons contrast OK |
| 8 | Toggle back to light mode | Seamless transition |

### E2E 5: Subscription Lifecycle -> Purchase -> Verify -> Cancel -> Verify Downgrade

**Device:** Physical Android device with sandbox account
**Pre-conditions:** Sandbox test account configured in Play Console

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Sign in with test account | Free tier active |
| 2 | Navigate to paywall | Plans displayed with prices |
| 3 | Purchase Weekly plan (sandbox) | Purchase completes, Pro badge shown |
| 4 | Verify unlimited summaries | No daily limit enforced |
| 5 | Verify PDF upload available | PDF picker works |
| 6 | Cancel subscription in Play Store settings | Cancellation confirmed |
| 7 | Wait for sandbox expiry (accelerated) | Subscription expires |
| 8 | Verify downgrade to free | Free tier badge, limits enforced |
| 9 | Tap "Restore Purchases" | Correctly shows no active subscription |

---

## 8. Test Coverage Targets

| Layer | Target | Metric | Measurement Command |
|-------|--------|--------|---------------------|
| Models | 95%+ | All fromJson/toJson/copyWith paths covered | `flutter test --coverage test/models/` |
| Services | 80%+ | All public methods, happy path + error path | `flutter test --coverage test/services/` |
| Controllers | 70%+ | All state transitions, major code paths | `flutter test --coverage test/controllers/` |
| Screens | 60%+ | Key interactions, all UI states rendered | `flutter test --coverage test/screens/` |
| Utils | 90%+ | Extensions, enums, exception hierarchy | `flutter test --coverage test/utils/` |
| **Overall** | **80%+** | Combined | `flutter test --coverage` |

### Coverage Enforcement

```bash
# Generate coverage report
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Check minimum threshold (CI gate)
# Fail build if overall coverage drops below 80%
```

### CI Integration

Coverage checks should be added to the GitHub Actions workflow:
- Run on every PR
- Block merge if coverage drops below target
- Upload coverage report as artifact

---

## 9. Test Data Factory

A shared factory at `test/helpers/test_factories.dart` provides:

- **Default instances** of every model with sensible test data
- **Override capability** for any field via optional named parameters
- **JSON helpers** for testing fromJson paths
- **List builders** for creating collections of test data

See: `test/helpers/test_factories.dart`

---

## 10. Test Infrastructure

### 10.1 Mock Services

All abstract interfaces have in-memory mock implementations at `test/helpers/mock_services.dart`:

- `MockLibraryStorage` -- in-memory Map<String, Map<String, dynamic>>
- `MockAuthProvider` -- configurable success/failure, in-memory user state
- `MockPurchaseProvider` -- configurable entitlements, in-memory state
- `MockUsageCache` -- in-memory cache Map
- `MockStreakStorage` -- in-memory streak data
- `MockClipboardProvider` -- configurable clipboard content

Each mock supports:
- **Configurable error injection** via `shouldThrow` flag
- **State inspection** for verifying service calls
- **Reset** to clear state between tests

### 10.2 Dependencies

Required dev dependencies in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_riverpod: # Already in dependencies
  mocktail: ^1.0.0        # For mocking classes
  http_mock_adapter: ^0.6.0  # For mocking Dio
  fake_async: ^1.3.0      # For controlling time in streak tests
```

### 10.3 Test Execution

```bash
# Run all tests
flutter test

# Run specific layer
flutter test test/models/
flutter test test/services/
flutter test test/controllers/

# Run with coverage
flutter test --coverage

# Run integration tests (requires device/emulator)
flutter test integration_test/

# Run single test file
flutter test test/models/summary_model_test.dart
```

### 10.4 Naming Conventions

- Test files: `<source_file>_test.dart` in matching directory structure
- Test groups: `group('ClassName', () { ... })`
- Test names: Start with verb -- `'returns', 'throws', 'emits', 'navigates'`
- Example: `test('returns SummaryModel when response is valid', () { ... })`
