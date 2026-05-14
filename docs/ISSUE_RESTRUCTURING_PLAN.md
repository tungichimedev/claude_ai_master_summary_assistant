# Issue Restructuring Plan: Layered Architecture

**Date:** 2026-05-14
**Author:** Tech Lead (Claude)
**Architecture:** Model -> Service -> Test -> Controller -> Screen -> Wire

---

## Summary

Split 28 existing monolithic issues into ~48 layered tickets following Service/Controller/UI separation.
Issues that are already single-layer (pure backend, pure UI, marketing, cross-cutting) stay as-is.

### Issues Being Split (10 issues -> 30 new tickets)

| Old # | Old Title | New Tickets |
|-------|-----------|-------------|
| #2 | Home Screen | -> 2 tickets (Controller + UI) |
| #3 | Universal Summarizer | -> 4 tickets (Service + Controller + UI Input + UI Result) |
| #4 | Offline Library | -> 3 tickets (Service + Controller + UI) |
| #5 | RevenueCat Subscription | -> 3 tickets (Service + Controller + UI Paywalls) |
| #6 | Shareable Cards | -> 2 tickets (Service + UI) |
| #8 | AI Experts | -> 3 tickets (Service + Controller + UI) |
| #10 | Referral | -> 2 tickets (Service + UI) |
| #12 | Streak | -> 2 tickets (Service + UI) |
| #17 | Email Writing | -> 2 tickets (Service + UI) |
| #21 | Firebase Auth | -> 3 tickets (Service + Controller + UI) |
| #25 | Churn Prevention | -> 2 tickets (Service + UI) |

### Issues Kept As-Is (17 issues)

| # | Title | Reason |
|---|-------|--------|
| #1 | Backend API | Pure backend |
| #7 | Onboarding | Pure UI, small |
| #9 | Rewarded Ads | Small, tightly coupled |
| #11 | Push Notifications | Backend + thin client handler |
| #13 | ASO | Marketing |
| #14 | Profile Screen | Pure UI (consumes other services) |
| #15 | Dark Mode | Cross-cutting theming |
| #16 | User Acquisition | Marketing |
| #22 | Privacy/Legal | Non-code + compliance |
| #23 | Content Safety | Cross-cutting |
| #24 | Remote Config | Infrastructure |
| #26 | Deep Linking | Infrastructure |
| #27 | Accessibility | Cross-cutting |
| #28 | QA Phase | Cross-cutting |
| #18 | OCR (v2.0) | Future milestone |
| #19 | Plus/Ultra tiers (v2.0) | Future milestone |
| #20 | YouTube (v2.5) | Future milestone |

### New Issues Added (2)

| Title | Reason |
|-------|--------|
| Analytics & Crashlytics | Missing from issue tracker, referenced in PRD Section 8.1 |
| Models & DTOs | Foundation layer needed before all services |

**Total after restructuring: ~49 tickets**

---

## Week-by-Week Plan with `gh issue create` Commands

### WEEK 1: Foundation (Backend + Auth + Models)

---

#### NEW #29: [Model] Core data models and DTOs

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Model] Core data models and DTOs: Summary, User, Expert, Subscription" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Define all core data models with toJson/fromJson/copyWith. This is the foundation layer that every service and controller depends on.

## Requirements
- [ ] `SummaryModel`: id, title, sourceUrl, sourceType (text/url/pdf), content, bulletPoints, format, createdAt, isFavorite, tags
- [ ] `UserModel`: uid, email, displayName, tier (free/pro), trialEndsAt, streakCount, referralCode, createdAt
- [ ] `UsageModel`: summariesUsed, tokensUsed, dailyReset, expertQueriesUsed
- [ ] `ExpertModel`: id, name, icon, description, systemPrompt, isLocked
- [ ] `ExpertMessageModel`: role, content, timestamp, structuredOutput (Map)
- [ ] `SubscriptionModel`: tier, status (active/trial/expired/cancelled), expiresAt, planId
- [ ] `CardTemplateModel`: id, name, aspectRatio, backgroundColor, textStyle
- [ ] `ReferralModel`: code, referredUsers, rewardsEarned
- [ ] `StreakModel`: currentStreak, longestStreak, lastSummaryDate, freezesRemaining
- [ ] All models have: toJson(), fromJson(), copyWith(), == operator, hashCode
- [ ] All models are immutable (use @freezed or manual)

## Acceptance Criteria
- [ ] All models compile with zero warnings
- [ ] toJson -> fromJson roundtrip preserves all fields (unit test)
- [ ] copyWith works for every field (unit test)
- [ ] Models handle null/missing fields gracefully (fromJson with defaults)

## Dependencies
- None (foundation)
- Blocks: ALL service tickets

## PRD Reference
Section 8.1 Architecture
EOF
)"
```

---

#### KEPT #1: Backend API (no change)

Already well-scoped as pure backend. No split needed.

---

#### NEW #30: [Service] Auth: Firebase anonymous, email, Google Sign-In, account linking

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Auth: Firebase anonymous, email, Google Sign-In, account linking" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Pure service layer for Firebase Authentication. No UI, no state management. Wraps FirebaseAuth SDK into a testable service with proper error handling.

## Requirements
- [ ] `AuthService` class with dependency injection (accepts FirebaseAuth instance)
- [ ] `signInAnonymously()` -> returns UserModel
- [ ] `signInWithEmail(email, password)` -> returns UserModel
- [ ] `signUpWithEmail(email, password, displayName)` -> returns UserModel
- [ ] `signInWithGoogle()` -> returns UserModel (Google Sign-In SDK)
- [ ] `linkAnonymousToEmail(email, password)` -> preserves uid
- [ ] `linkAnonymousToGoogle()` -> preserves uid
- [ ] `signOut()` -> clears auth state
- [ ] `getCurrentUser()` -> UserModel?
- [ ] `authStateChanges()` -> Stream<UserModel?>
- [ ] Error mapping: FirebaseAuthException -> domain errors (EmailAlreadyExists, WeakPassword, NetworkError, etc.)
- [ ] Auth state persistence (FirebaseAuth handles this, but verify)

## Acceptance Criteria
- [ ] Anonymous auth completes in < 2s (test with real Firebase)
- [ ] Account linking preserves uid (integration test)
- [ ] All error types mapped to domain errors (unit test with mocks)
- [ ] Service is fully testable with mocked FirebaseAuth

## Dependencies
- Depends on: #29 (UserModel)
- Blocks: #31 (Auth Controller), #32 (Auth UI)

## Replaces part of: #21
EOF
)"
```

---

#### NEW #31: [Controller] Auth: Riverpod state management for auth flows

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Controller] Auth: Riverpod AsyncNotifier for auth state" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Riverpod AsyncNotifier that manages auth state. Consumes AuthService, exposes reactive state to UI. Handles auto-anonymous-auth on first launch.

## Requirements
- [ ] `AuthController extends AsyncNotifier<UserModel?>`
- [ ] Auto-trigger anonymous auth on first launch (no UI)
- [ ] `signIn(email, password)` -> AsyncValue<UserModel>
- [ ] `signUp(email, password, name)` -> AsyncValue<UserModel>
- [ ] `signInWithGoogle()` -> AsyncValue<UserModel>
- [ ] `linkAccount(provider)` -> AsyncValue<UserModel>
- [ ] `signOut()` -> AsyncValue<void>
- [ ] `authStateProvider` -> StreamProvider that wraps authStateChanges()
- [ ] `isAuthenticatedProvider` -> derived Provider<bool>
- [ ] Error state handling: expose typed errors for UI to display
- [ ] Loading state during auth operations

## Acceptance Criteria
- [ ] Anonymous auth fires automatically, controller state = AsyncData(user) within 2s
- [ ] Auth errors surface as AsyncError with typed domain error
- [ ] Sign out resets state to AsyncData(null)
- [ ] Controller unit tests with mocked AuthService (5+ tests)

## Dependencies
- Depends on: #30 (AuthService)
- Blocks: #32 (Auth UI), #1 (backend needs auth tokens)

## Replaces part of: #21
EOF
)"
```

---

#### NEW #32: [UI] Auth: Sign-in/sign-up screen, Google one-tap, error states

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Auth: Sign-in/sign-up screen, Google one-tap, error states" \
  --label "P0-critical,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Login/signup UI screens. Consumes AuthController. Shows only when user wants to upgrade from anonymous to permanent account (NOT on first launch -- first launch is silent anonymous).

## Requirements
- [ ] Sign-in screen: email field, password field, "Sign In" button, "Sign in with Google" button
- [ ] Sign-up screen: name, email, password fields, "Create Account" button, Google button
- [ ] Toggle between sign-in and sign-up
- [ ] Inline validation: email format, password min 6 chars
- [ ] Loading state: button spinner during auth
- [ ] Error state: "Email already exists", "Wrong password", "Network error" with retry
- [ ] Google one-tap UI integration
- [ ] "Forgot password" link -> Firebase password reset email
- [ ] Account linking prompt for anonymous users (bottom sheet)
- [ ] Sign-out confirmation dialog with "Keep local data?" option

## Acceptance Criteria
- [ ] Sign-up with email -> account created -> navigates to Home
- [ ] Google Sign-In -> one-tap -> account created -> Home
- [ ] Wrong password -> inline error, field highlighted
- [ ] Network error -> snackbar with retry
- [ ] Dark mode renders correctly
- [ ] All touch targets >= 48dp

## Dependencies
- Depends on: #31 (AuthController)
- Blocks: #7 (onboarding needs auth complete)

## Replaces part of: #21
EOF
)"
```

---

### WEEK 2-3: Core Summarizer (the product)

---

#### NEW #33: [Service] Summarizer: API client, streaming, token budget, format switching

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Summarizer: API client, streaming, token budget, format switching" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Pure business logic for the summarization engine. Handles API communication with backend Cloud Functions, streaming response parsing, token budget tracking, and client-side format switching. NO UI code.

## Requirements
- [ ] `SummarizerService` class
- [ ] `summarizeText(text, format)` -> Stream<String> (streaming response)
- [ ] `summarizeUrl(url, format)` -> Stream<String> (backend extracts text)
- [ ] `summarizePdf(fileBytes, format)` -> Stream<String> (backend extracts text)
- [ ] `switchFormat(rawContent, newFormat)` -> String (client-side reformat, no API call)
- [ ] `cancelSummarization()` -> cancels HTTP stream
- [ ] Streaming parser: handles SSE/chunked response from Cloud Functions
- [ ] Token budget check before request (call GET /usage first)
- [ ] Error handling: NetworkError, RateLimitError, BudgetExceededError, ContentTooLongError, ExtractionFailedError
- [ ] Input validation: text length limits per tier, URL format validation, PDF size limits
- [ ] Response parsing: extract bullet points, paragraphs, takeaways, action items from AI response

## Acceptance Criteria
- [ ] Text summary: 2000 words in -> bullet points out within 10s (integration test)
- [ ] URL summary: valid URL -> summary within 15s
- [ ] Streaming: first token displays within 2s of request
- [ ] Format switching: bullet -> paragraph without new API call (unit test)
- [ ] Cancel: ongoing request cancelled, stream closed (unit test)
- [ ] Budget exceeded: throws BudgetExceededError (unit test with mock)
- [ ] Network failure: throws NetworkError with retryable flag

## Dependencies
- Depends on: #1 (backend API), #29 (SummaryModel)
- Blocks: #34 (Summarizer Controller)

## Replaces part of: #3
EOF
)"
```

---

#### NEW #34: [Controller] Summarizer: Riverpod state for input, streaming, results

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Controller] Summarizer: Riverpod AsyncNotifier for summary state" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Riverpod controller managing the full summarization lifecycle: input validation -> API call -> streaming display -> result storage. Bridges SummarizerService and LibraryService.

## Requirements
- [ ] `SummarizerController extends AsyncNotifier<SummaryState>`
- [ ] `SummaryState`: idle, validating, loading(progress), streaming(partialText), success(SummaryModel), error(DomainError)
- [ ] `startSummary(type, content)` -> validates input -> calls service -> streams result
- [ ] `switchFormat(format)` -> client-side reformat (no loading state)
- [ ] `cancel()` -> stops streaming, returns to idle
- [ ] `retry()` -> re-runs last request
- [ ] Auto-save: on success, calls LibraryService.save()
- [ ] `usageProvider` -> exposes remaining summaries count (synced with backend)
- [ ] `clipboardProvider` -> detects URL/text in clipboard on app foreground
- [ ] Loading progress text cycling: "Extracting content..." -> "Analyzing..." -> "Generating summary..."

## Acceptance Criteria
- [ ] State transitions: idle -> loading -> streaming -> success (unit test)
- [ ] Error state: network failure -> error with retry action (unit test)
- [ ] Cancel mid-stream -> state returns to idle (unit test)
- [ ] Format switch -> immediate state update, no loading flicker
- [ ] Auto-save verified: success -> library contains new item
- [ ] 5+ unit tests with mocked SummarizerService

## Dependencies
- Depends on: #33 (SummarizerService), #36 (LibraryService for auto-save)
- Blocks: #35 (Summary Input UI), #35b (Summary Result UI)

## Replaces part of: #3
EOF
)"
```

---

#### NEW #35: [UI] Summary Input: text/URL/PDF tabs, clipboard banner, Share Intent

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Summary Input: text/URL/PDF tabs, clipboard banner, Share Intent" \
  --label "P0-critical,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
The input portion of the summarizer: tabbed input area (Text/URL/PDF), clipboard detection banner, and Android Share Intent receiver. This is the top half of the Home screen.

## Requirements
- [ ] Three input tabs: Text / URL / PDF (chip-style toggles)
- [ ] Text tab: multiline TextField with character count, "Summarize" button
- [ ] URL tab: single-line URL field with paste button, "Summarize" button
- [ ] PDF tab: file picker button, selected file name display, page count, "Summarize" button
- [ ] Clipboard detection banner: appears at top when URL/long-text detected in clipboard
  - [ ] Shows preview of clipboard content (truncated)
  - [ ] "Summarize" and "Dismiss" actions
  - [ ] Appears within 1s of app foregrounding
- [ ] Android Share Intent handler:
  - [ ] Intent filter for text/plain and text/html
  - [ ] Receive URL from Chrome/other apps
  - [ ] Auto-fill URL tab and start summarization
- [ ] Guided first-run tooltip on Summarize button (for new users after onboarding)
- [ ] PDF: show micro-paywall if free user tries to upload (allows 3 pages max)
- [ ] Input validation: visual feedback for invalid URL, empty text, oversized PDF

## Acceptance Criteria
- [ ] Paste URL -> tap Summarize -> loading state begins within 500ms
- [ ] Clipboard banner: copy URL in Chrome -> open app -> banner appears < 1s
- [ ] Share Intent: share URL from Chrome -> app opens with URL pre-filled -> summary starts
- [ ] PDF picker: select file -> filename shown -> tap Summarize
- [ ] Free user + PDF > 3 pages -> micro-paywall shown
- [ ] Dark mode correct
- [ ] All touch targets >= 48dp

## Dependencies
- Depends on: #34 (SummarizerController for state)
- Part of: Home screen (#2 replacement)

## Replaces part of: #3, #2
EOF
)"
```

---

#### NEW #35b: [UI] Summary Result: streaming display, format chips, action bar

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Summary Result: streaming display, format chips, action bar" \
  --label "P0-critical,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
The result screen shown after summarization completes. Displays streaming text, format switching chips, and action buttons (Save/Share/Card/Copy).

## Requirements
- [ ] Source info header: title + favicon + "2,347 words -> 5 key points"
- [ ] Streaming text display: characters appear with subtle fade-in
- [ ] Shimmer skeleton during initial loading (before first token)
- [ ] Progress bar with cycling status text
- [ ] Cancel button (back arrow) -> confirms abort mid-stream
- [ ] Format chips: Bullets | Paragraph | Takeaways | Action Items
  - [ ] Tapping chip switches format instantly (no reload)
  - [ ] Active chip visually highlighted
- [ ] Bullet points display with proper indentation and bullet markers
- [ ] Action bar (bottom): Save | Share | Card | Copy
  - [ ] Save: fly-to-library animation
  - [ ] Share: Android share sheet with formatted text
  - [ ] Card: navigate to Card Creator (#6)
  - [ ] Copy: copy to clipboard with snackbar confirmation
- [ ] Per-bullet "Share This Insight" button (long-press or icon)
- [ ] Error state: "Connection lost. Retry?" with retry button
- [ ] Network failure mid-stream: show partial content + error banner + retry
- [ ] AI disclaimer footer: "AI-generated summary. May contain errors."

## Acceptance Criteria
- [ ] Streaming: text appears character-by-character smoothly (60fps)
- [ ] Format switch: instant, no loading indicator
- [ ] Copy: text in clipboard matches displayed content
- [ ] Share: share sheet opens with formatted text
- [ ] Error mid-stream: partial text preserved, retry resumes
- [ ] Dark mode correct
- [ ] Shimmer -> content transition is smooth

## Dependencies
- Depends on: #34 (SummarizerController)
- Blocks: #6 (Card Creator accessed from action bar)

## Replaces part of: #3
EOF
)"
```

---

### WEEK 2 (parallel): Home Screen

---

#### NEW #37: [Controller] Home: orchestrates clipboard, usage, recent summaries, daily summary

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Controller] Home: clipboard detection, usage counter, recent summaries" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Riverpod controller that orchestrates the Home screen state: clipboard detection, usage counter synchronization, recent summaries list, and Summary of the Day.

## Requirements
- [ ] `clipboardDetectionProvider`: checks clipboard on app foreground, exposes ClipboardContent? (url or long text)
- [ ] `usageCounterProvider`: exposes "X of 5 remaining" synced with backend
- [ ] `recentSummariesProvider`: last 5 summaries from LibraryService
- [ ] `summaryOfDayProvider`: cached daily trending summary from backend GET /daily-summary
- [ ] `streakCountProvider`: current streak count from StreakService
- [ ] `dismissClipboard()`: hides banner until next foreground
- [ ] `acceptClipboard()`: passes content to SummarizerController

## Acceptance Criteria
- [ ] Clipboard detected within 1s of foreground (unit test with mock)
- [ ] Usage counter updates after each summary (reactive)
- [ ] Recent summaries updates when library changes (reactive)
- [ ] Summary of the Day caches for 24 hours

## Dependencies
- Depends on: #34 (SummarizerController), #36 (LibraryService), #42 (StreakService)
- Blocks: #38 (Home UI)

## Replaces part of: #2
EOF
)"
```

---

#### NEW #38: [UI] Home Screen: summary-first layout, tabs, recent, daily summary

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Home Screen: summary-first layout, bottom tabs, recent summaries" \
  --label "P0-critical,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
The main Home screen UI. Summary-first layout with clipboard banner, input area (delegates to Summary Input widget), streak badge, usage counter, Summary of the Day card, recent summaries carousel, and bottom tab bar.

## Requirements
- [ ] Clipboard banner at top (from clipboardDetectionProvider)
- [ ] Summary input area (embeds Summary Input widget from #35)
- [ ] Streak badge in header: fire icon + count (from streakCountProvider)
- [ ] Usage counter pill: "X of 5 remaining" (from usageCounterProvider)
- [ ] "Summary of the Day" card: trending article summary, tappable
- [ ] Recent summaries horizontal scroll: last 5, tappable -> opens full summary
- [ ] Bottom tab bar: Summarize | Experts | Library | Profile
- [ ] Empty state (new user): guided tooltip on Summarize button
- [ ] Error state (offline): banner + cached recent summaries visible
- [ ] Pull-to-refresh with custom app logo animation
- [ ] Loading state: shimmer for Summary of the Day and recent summaries

## Acceptance Criteria
- [ ] Home loads within 3s cold start
- [ ] Clipboard banner appears within 1s of app foreground
- [ ] Tab navigation works between all 4 tabs
- [ ] Recent summaries scroll horizontally, tap opens detail
- [ ] Dark mode renders correctly
- [ ] Empty state shows for brand new users

## Dependencies
- Depends on: #37 (HomeController), #35 (Summary Input widget)
- Blocks: #7 (onboarding CTA navigates here)

## Replaces: #2
EOF
)"
```

---

### WEEK 3-4: Offline Library

---

#### NEW #36: [Service] Library: Hive/Isar storage, search, CRUD, tier limits

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Library: Hive/Isar local storage, search, CRUD, tier limits" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Pure service layer for the offline summary library. Handles local persistence with Hive or Isar, full-text search, CRUD operations, and free-tier item limits.

## Requirements
- [ ] `LibraryService` class with dependency injection
- [ ] `saveSummary(SummaryModel)` -> stores locally, enforces tier limit (20 free / unlimited Pro)
- [ ] `getSummaries({filter, sortBy, query})` -> List<SummaryModel>
- [ ] `searchSummaries(query)` -> full-text search across title + content + tags
- [ ] `deleteSummary(id)` -> removes from local storage
- [ ] `toggleFavorite(id)` -> updates isFavorite flag
- [ ] `addTag(id, tag)` / `removeTag(id, tag)`
- [ ] `getCount()` -> int (for usage display)
- [ ] `getRecentSummaries(limit)` -> last N summaries
- [ ] Filter options: All / Articles / PDFs / Favorites
- [ ] Sort options: Date (newest) / Date (oldest) / Alphabetical
- [ ] Tier limit enforcement: throws LibraryFullError when free user exceeds 20 items
- [ ] Data migration strategy for schema changes

## Acceptance Criteria
- [ ] Save + retrieve roundtrip preserves all fields (unit test)
- [ ] Search finds partial matches in title and content (unit test)
- [ ] Free user at 20 items -> save throws LibraryFullError (unit test)
- [ ] Pro user -> unlimited saves (unit test)
- [ ] Delete removes item permanently (unit test)
- [ ] Filter by type returns correct subset (unit test)
- [ ] 100 items: search returns in < 100ms

## Dependencies
- Depends on: #29 (SummaryModel)
- Blocks: #39 (Library Controller), #34 (Summarizer auto-save)

## Replaces part of: #4
EOF
)"
```

---

#### NEW #39: [Controller] Library: Riverpod state for list, search, filters

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Controller] Library: Riverpod state for list, search, filters" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Riverpod controller managing library list state, search queries, active filters, and sort order.

## Requirements
- [ ] `LibraryController extends AsyncNotifier<List<SummaryModel>>`
- [ ] `searchQuery` state provider
- [ ] `activeFilter` state provider (All/Articles/PDFs/Favorites)
- [ ] `sortOrder` state provider (newest/oldest/alpha)
- [ ] `filteredSummariesProvider` -> computed from all three above
- [ ] `deleteSummary(id)` -> optimistic delete + undo support
- [ ] `toggleFavorite(id)` -> optimistic toggle
- [ ] `libraryCountProvider` -> reactive count for usage display
- [ ] Refresh on new summary saved (listen to save events)

## Acceptance Criteria
- [ ] Filter change -> list updates immediately (unit test)
- [ ] Search debounced at 300ms (unit test)
- [ ] Delete + undo within 5s restores item
- [ ] Count updates reactively when items added/removed
- [ ] 5+ unit tests

## Dependencies
- Depends on: #36 (LibraryService)
- Blocks: #40 (Library UI)

## Replaces part of: #4
EOF
)"
```

---

#### NEW #40: [UI] Library: card list, search bar, filters, swipe actions, empty/error states

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Library: card list, search, filters, swipe actions, empty/error states" \
  --label "P0-critical,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
The Library tab UI showing saved summaries as searchable, filterable card list with swipe actions.

## Requirements
- [ ] Sticky search bar at top (remains visible when scrolling)
- [ ] Filter chips below search: All / Articles / PDFs / Favorites
- [ ] Card list: title, source icon, date, 2-line preview, tags
- [ ] Swipe-left to delete (with undo snackbar)
- [ ] Swipe-right to share
- [ ] Tap card -> opens full summary result screen
- [ ] Usage progress bar: "X of 20 free summaries" (for free users)
- [ ] Empty state: illustration + "No summaries yet" + "Summarize your first article" CTA
- [ ] Empty search state: "No results for [query]"
- [ ] Error state (offline): "Showing cached summaries" banner
- [ ] Loading state: shimmer skeletons
- [ ] Pull-to-refresh
- [ ] Free user at limit: banner "Library full. Upgrade to save more."

## Acceptance Criteria
- [ ] Search: type query -> results filter in real-time (debounced)
- [ ] Filter chip: tap -> list updates immediately
- [ ] Swipe-left: card animates out, undo snackbar appears for 5s
- [ ] Empty state: CTA navigates to Summarize tab
- [ ] 100+ items: scrolls smoothly at 60fps
- [ ] Dark mode correct
- [ ] All touch targets >= 48dp

## Dependencies
- Depends on: #39 (LibraryController)

## Replaces part of: #4
EOF
)"
```

---

### WEEK 4: AI Experts

---

#### NEW #41: [Service] AI Experts: system prompts, structured output parsing, streaming

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] AI Experts: system prompts, API client, structured output parsing" \
  --label "P1-high,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Service layer for AI Expert modules. Manages expert definitions, system prompts, API calls through backend, and parsing structured output (workout cards, social media previews).

## Requirements
- [ ] `ExpertService` class
- [ ] `getExperts()` -> List<ExpertModel> (2 active + 4 locked)
- [ ] `sendMessage(expertId, message, history)` -> Stream<String> (streaming)
- [ ] `parseStructuredOutput(expertId, rawResponse)` -> Map<String, dynamic>
- [ ] Social Media expert: parse Instagram preview, hashtag list, posting time
- [ ] Fitness expert: parse workout table (exercise, sets, reps, rest), nutrition info
- [ ] System prompts stored as assets (not hardcoded in service)
- [ ] Conversation history management (last N messages for context)
- [ ] Save expert response to library (via LibraryService)

## Acceptance Criteria
- [ ] Social Media query -> structured output with hashtags array (unit test)
- [ ] Fitness query -> structured workout card (unit test)
- [ ] Streaming works same as summarizer (first token < 2s)
- [ ] Locked expert -> throws FeatureLockedError
- [ ] 5+ unit tests

## Dependencies
- Depends on: #1 (POST /expert endpoint), #29 (ExpertModel, ExpertMessageModel)
- Blocks: #41b (Expert Controller)

## Replaces part of: #8
EOF
)"
```

---

#### NEW #41b: [Controller] AI Experts: chat state, message history, expert selection

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Controller] AI Experts: Riverpod state for chat, history, expert selection" \
  --label "P1-high,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Riverpod controller for managing expert chat interactions, message history, and expert grid state.

## Requirements
- [ ] `ExpertListProvider` -> List<ExpertModel> with locked/unlocked status
- [ ] `SelectedExpertProvider` -> currently active expert
- [ ] `ExpertChatController extends AsyncNotifier<List<ExpertMessageModel>>`
- [ ] `sendMessage(text)` -> appends user message -> streams AI response -> appends AI message
- [ ] `clearChat()` -> resets conversation
- [ ] `saveResponse(messageId)` -> saves to library via LibraryService
- [ ] Streaming state: isTyping flag while AI responds
- [ ] Error handling: network failure, rate limit, locked expert

## Acceptance Criteria
- [ ] Send message -> message appears in list -> AI response streams in (unit test)
- [ ] Clear chat -> empty list (unit test)
- [ ] Save response -> appears in library
- [ ] Locked expert tap -> error state with upgrade CTA info
- [ ] 5+ unit tests

## Dependencies
- Depends on: #41 (ExpertService), #36 (LibraryService)
- Blocks: #41c (Expert UI)

## Replaces part of: #8
EOF
)"
```

---

#### NEW #41c: [UI] AI Experts: expert grid, chat interface, structured output cards

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] AI Experts: expert grid, chat interface, structured output cards" \
  --label "P1-high,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
The Experts tab: 2-column expert grid + chat interface with structured output cards (NOT plain chat bubbles).

## Requirements
### Expert Grid (Experts tab)
- [ ] 2-column grid: Social Media (active) + Fitness (active) + 4 locked
- [ ] Locked experts: lock icon + "Coming Soon" overlay
- [ ] Tapping locked expert -> micro-paywall bottom sheet
- [ ] Expert cards: icon, name, short description

### Chat Interface (after selecting expert)
- [ ] "AI Assistant" label in header (not "Online")
- [ ] User message bubble (right-aligned)
- [ ] AI response as structured card (NOT chat bubble):
  - Social Media: Instagram preview card, hashtag chips, posting time suggestion
  - Fitness: workout card with exercise table (name, sets, reps, rest), nutrition tips
- [ ] Streaming indicator ("typing..." with animated dots)
- [ ] Action buttons on each AI response: Copy, Save to Library, Share, Modify
- [ ] Suggested prompt chips at bottom for new users
- [ ] Empty state: "Ask [Expert Name] anything about [topic]"

### Error States
- [ ] Network error: "Connection lost. Retry?" banner
- [ ] Rate limit: "You've reached today's limit" with upgrade CTA
- [ ] Loading: shimmer for AI response card

## Acceptance Criteria
- [ ] Grid: 2 active + 4 locked experts visible
- [ ] Locked expert tap -> micro-paywall appears
- [ ] Fitness query -> workout card with table layout (not raw text)
- [ ] Social media query -> post preview with hashtag chips
- [ ] Save button -> expert response saved to Library
- [ ] Dark mode correct
- [ ] Streaming animation smooth at 60fps

## Dependencies
- Depends on: #41b (ExpertChatController)

## Replaces part of: #8
EOF
)"
```

---

### WEEK 4-5: Streak + Onboarding

---

#### NEW #42: [Service] Streak: consecutive day tracking, milestones, freeze logic

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Streak: day tracking, milestones, freeze logic, local storage" \
  --label "P1-high,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Pure business logic for the summary streak system. Tracks consecutive days, handles timezone edge cases, milestone detection, and streak freeze.

## Requirements
- [ ] `StreakService` class
- [ ] `recordActivity()` -> updates streak based on current date
- [ ] `getStreak()` -> StreakModel (current, longest, last date, freezes)
- [ ] `useFreeze()` -> consumes one freeze (Pro users: 1/week)
- [ ] Day boundary logic: uses device timezone, resets at midnight local
- [ ] Streak break detection: if yesterday had no activity AND no freeze -> reset to 0
- [ ] Milestone detection: returns milestone type at 7, 30, 100 days
- [ ] Local storage: persist streak data in Hive/SharedPreferences
- [ ] Edge cases: timezone change, device clock manipulation, app not opened for days

## Acceptance Criteria
- [ ] Day 1 summary -> streak = 1 (unit test)
- [ ] Day 1 + Day 2 summary -> streak = 2 (unit test)
- [ ] Day 1 + skip Day 2 + Day 3 -> streak = 1 (reset, unit test)
- [ ] Day 1 + freeze Day 2 + Day 3 -> streak = 3 (unit test)
- [ ] 7-day milestone detected (unit test)
- [ ] Timezone edge case: summary at 11:59 PM + 12:01 AM = 2 different days (unit test)

## Dependencies
- Depends on: #29 (StreakModel)
- Blocks: #42b (Streak UI), #37 (Home Controller uses streak)

## Replaces part of: #12
EOF
)"
```

---

#### NEW #42b: [UI] Streak: badge on Home, calendar on Profile, milestone celebrations

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Streak: badge on Home, calendar on Profile, milestone celebrations" \
  --label "P1-high,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
UI components for the streak system: fire badge on Home header, 14-day calendar on Profile, and milestone celebration overlays.

## Requirements
- [ ] Home header streak badge: fire icon + count with pop/scale animation on increment
- [ ] Profile: 14-day streak calendar (filled circles for active days, empty for missed)
- [ ] Milestone celebrations: confetti animation + "7-day streak!" modal at 7, 30, 100 days
- [ ] Streak-break state: "Start a new streak!" encouragement
- [ ] Streak freeze indicator on Profile (Pro users): "1 freeze remaining this week"
- [ ] Haptic feedback: medium haptic on milestone

## Acceptance Criteria
- [ ] Badge updates reactively when streak changes
- [ ] Calendar shows correct 14-day history
- [ ] Confetti animation plays at milestone (widget test)
- [ ] Dark mode correct
- [ ] Respects "reduce motion" system setting

## Dependencies
- Depends on: #42 (StreakService, exposed via provider)
- Integrates into: #38 (Home screen), #14 (Profile screen)

## Replaces part of: #12
EOF
)"
```

---

#### KEPT #7: 1-screen onboarding (no change)

Already well-scoped as pure UI with hardcoded content. No split needed.

---

### WEEK 5-6: Subscription + Paywall

---

#### NEW #43: [Service] Subscription: RevenueCat SDK, tier management, trial tracking

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Subscription: RevenueCat SDK, tier management, trial tracking" \
  --label "P0-critical,flutter,monetization" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Pure service layer wrapping RevenueCat SDK. Handles subscription state, tier detection, trial tracking, restore purchases, and A/B offering management.

## Requirements
- [ ] `SubscriptionService` class
- [ ] `initialize()` -> configure RevenueCat with API key, identify user
- [ ] `getCurrentSubscription()` -> SubscriptionModel (tier, status, expiresAt)
- [ ] `getOfferings()` -> list of available packages (weekly/monthly/annual)
- [ ] `purchase(packageId)` -> initiates Google Play billing, returns result
- [ ] `restorePurchases()` -> checks for existing subscriptions
- [ ] `isProUser()` -> bool (active subscription OR active trial)
- [ ] `getTrialDaysRemaining()` -> int?
- [ ] `subscriptionStream()` -> Stream<SubscriptionModel> (real-time updates)
- [ ] A/B variant detection: which paywall offering to show (via RevenueCat experiments)
- [ ] Error handling: BillingError, RestoreFailedError, NetworkError
- [ ] Sandbox detection for testing

## Acceptance Criteria
- [ ] Free user: isProUser() = false (unit test with mock)
- [ ] Purchase -> isProUser() = true within 5s (integration test)
- [ ] Restore: existing subscription detected and applied
- [ ] Trial: 7-day trial -> trialDaysRemaining decrements correctly
- [ ] Offline: last known state cached, no crash
- [ ] A/B: correct offering returned per variant

## Dependencies
- Depends on: #29 (SubscriptionModel), #1 (server-side validation)
- Blocks: #44 (Subscription Controller)

## Replaces part of: #5
EOF
)"
```

---

#### NEW #44: [Controller] Subscription: Riverpod state for tier, trial, paywall triggers

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Controller] Subscription: Riverpod state for tier, trial, paywall triggers" \
  --label "P0-critical,flutter,monetization" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Riverpod controller that exposes subscription state to the entire app. Determines when to show paywalls, which features are locked, and trial countdown state.

## Requirements
- [ ] `subscriptionProvider` -> StreamProvider<SubscriptionModel> (real-time from RevenueCat)
- [ ] `isProProvider` -> Provider<bool> (derived)
- [ ] `tierProvider` -> Provider<Tier> (free/pro)
- [ ] `trialBadgeProvider` -> Provider<String?> ("Pro Trial: 5 days left")
- [ ] `shouldShowSoftPaywall(summaryCount)` -> bool (after 2nd summary)
- [ ] `shouldShowHardPaywall(summaryCount)` -> bool (at limit)
- [ ] `canAccessFeature(feature)` -> bool (PDF upload, shareable cards, etc.)
- [ ] `purchase(packageId)` -> handles purchase flow, updates state
- [ ] `restorePurchases()` -> handles restore, shows result
- [ ] Paywall variant provider (A/B/C from RevenueCat)

## Acceptance Criteria
- [ ] isProProvider updates within 5s of purchase
- [ ] Trial badge shows correct days remaining
- [ ] Soft paywall triggers after 2nd summary (unit test)
- [ ] Hard paywall triggers at limit (unit test)
- [ ] Feature gating: free user cant access PDF > 3 pages (unit test)
- [ ] 5+ unit tests

## Dependencies
- Depends on: #43 (SubscriptionService)
- Blocks: #45 (Paywall UI)

## Replaces part of: #5
EOF
)"
```

---

#### NEW #45: [UI] Paywall: soft/hard/micro variants, trial badge, restore purchases

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Paywall: soft/hard/micro paywall screens, trial badge, restore" \
  --label "P0-critical,flutter,design,monetization" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
All paywall UI: soft paywall (bottom sheet after 2nd summary), hard paywall (full screen at limit), micro-paywall (bottom sheet for locked features), and trial countdown badge.

## Requirements
### Soft Paywall (bottom sheet)
- [ ] Time-saved stat: "You just saved 8 minutes"
- [ ] "Then $9.99/mo" price transparency
- [ ] "Start 7-Day Free Trial" CTA
- [ ] Dismiss button (subtle)

### Hard Paywall (full screen)
- [ ] Bold benefit headline: "Summarize anything. Learn 10x faster."
- [ ] Three feature bullets with icons
- [ ] Social proof: "Join early adopters" (honest, no fake numbers)
- [ ] Plan toggle: Monthly / Annual (annual pre-selected, "Save 50%" badge)
- [ ] Weekly plan option
- [ ] Large CTA: "Start 7-Day Free Trial" + subtext: "Then $9.99/mo. Cancel anytime."
- [ ] "Restore Purchases" link
- [ ] "Terms" and "Privacy" links

### Micro-Paywall (bottom sheet)
- [ ] Context-specific: "Unlock PDF uploads" / "Unlock shareable cards"
- [ ] Feature preview + price
- [ ] CTA: "Start Free Trial"

### Trial Badge
- [ ] "Pro Trial: X days left" badge on Home screen
- [ ] Visible throughout trial period
- [ ] Tappable -> opens subscription management

### A/B Variants
- [ ] Variant A: soft after 2nd + hard at limit
- [ ] Variant B: hard after onboarding with trial
- [ ] Variant C: friction-based (ads before results)

## Acceptance Criteria
- [ ] Soft paywall: appears as bottom sheet, dismissible
- [ ] Hard paywall: blocks content, requires action
- [ ] Purchase: Google Play billing flow completes -> paywall dismisses -> Pro features unlock
- [ ] Restore: "No purchases found" or successfully restores
- [ ] Trial badge: shows correct countdown, disappears after conversion
- [ ] All paywall screens render in dark mode
- [ ] Price displays correctly for user's locale

## Dependencies
- Depends on: #44 (SubscriptionController)

## Replaces part of: #5
EOF
)"
```

---

### WEEK 6: Shareable Cards + Email

---

#### NEW #46: [Service] Card Generator: image rendering, templates, watermark

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Card Generator: image rendering, templates, watermark logic" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Service that generates shareable summary card images. Handles template selection, text layout, watermark logic, and image export via RepaintBoundary.

## Requirements
- [ ] `CardGeneratorService` class
- [ ] `generateCard(summary, template, aspectRatio, selectedBullets)` -> Uint8List (PNG)
- [ ] 4 templates: Light, Dark, Colorful, Minimal
- [ ] 3 aspect ratios: Story (9:16), Square (1:1), Wide (16:9)
- [ ] Bullet point selection: include/exclude specific bullets
- [ ] Watermark: "Made with AI Master" (always on for free users, toggle for Pro)
- [ ] `saveToGallery(imageBytes)` -> saves to device photo gallery
- [ ] `shareImage(imageBytes)` -> launches Android share sheet with image
- [ ] Image quality: min 1080px width for social media

## Acceptance Criteria
- [ ] Generated image contains selected bullets (visual verification)
- [ ] Free user: watermark always present (unit test)
- [ ] Pro user: watermark toggleable (unit test)
- [ ] All 4 templates x 3 ratios = 12 combinations render correctly
- [ ] Save to gallery succeeds (integration test)
- [ ] Share sheet opens with correct image

## Dependencies
- Depends on: #29 (SummaryModel, CardTemplateModel)
- Blocks: #47 (Card Creator UI)

## Replaces part of: #6
EOF
)"
```

---

#### NEW #47: [UI] Card Creator: template picker, preview, export, share

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Card Creator: template picker, live preview, bullet selection, export" \
  --label "P0-critical,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Card creator screen accessed from Summary Result action bar. Live preview with template/ratio selection, bullet point checkboxes, and export actions.

## Requirements
- [ ] Template row: 4 template thumbnails (Light/Dark/Colorful/Minimal), tappable
- [ ] Aspect ratio selector: Story / Square / Wide chips
- [ ] Live preview: updates in real-time as selections change
- [ ] Bullet point checkboxes: select/deselect which points appear on card
- [ ] Watermark toggle (Pro users only; always on for free with lock icon)
- [ ] "Save to Gallery" button
- [ ] "Share" button -> Android share sheet
- [ ] Loading state: generating spinner while image renders
- [ ] RepaintBoundary wrapping preview for image capture

## Acceptance Criteria
- [ ] Template change -> preview updates instantly
- [ ] Aspect ratio change -> preview resizes with animation
- [ ] Uncheck bullet -> disappears from preview
- [ ] Save -> image in gallery, snackbar confirms
- [ ] Share -> share sheet with correct image
- [ ] Free user: watermark visible, toggle disabled
- [ ] Dark mode correct

## Dependencies
- Depends on: #46 (CardGeneratorService)
- Accessed from: #35b (Summary Result action bar)

## Replaces part of: #6
EOF
)"
```

---

#### NEW #48: [Service] Email Writer: compose, reply, tone selection, grammar fix

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Email Writer: compose, reply, tone, grammar fix via API" \
  --label "P1-high,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Service layer for email writing assistant. Handles API calls for composing, replying, tone adjustment, and grammar fixing.

## Requirements
- [ ] `EmailService` class
- [ ] `composeEmail(intent, tone)` -> Stream<String> (streaming)
- [ ] `replyToEmail(originalEmail, intent, tone)` -> Stream<String>
- [ ] `fixGrammar(text)` -> String (non-streaming, quick)
- [ ] Tone options: Professional, Casual, Friendly, Persuasive, Apologetic
- [ ] Save drafts to library via LibraryService

## Acceptance Criteria
- [ ] Compose: intent "meeting follow-up" + Professional -> formal email draft (integration test)
- [ ] Reply mode: original email context preserved in output
- [ ] Grammar fix: corrects common errors (unit test with examples)
- [ ] All tones produce noticeably different output

## Dependencies
- Depends on: #1 (POST /email endpoint), #36 (LibraryService for draft saving)
- Blocks: #49 (Email UI)

## Replaces part of: #17
EOF
)"
```

---

#### NEW #49: [UI] Email Writer: compose/reply screen, tone selector, copy/share

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Email Writer: compose/reply screen, tone selector, output actions" \
  --label "P1-high,flutter,design" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Email writing UI: compose from scratch or reply mode, tone selector chips, streaming output, and copy/share/save actions.

## Requirements
- [ ] Mode toggle: Compose / Reply
- [ ] Compose: intent text field ("What is this email about?")
- [ ] Reply: original email paste field + intent field
- [ ] Tone selector chips: Professional / Casual / Friendly / Persuasive / Apologetic
- [ ] Grammar fix mode: paste text -> get corrected version
- [ ] Streaming output display (reuse streaming widget from Summary Result)
- [ ] Action buttons: Copy / Share / Save Draft
- [ ] Loading state: shimmer while generating
- [ ] Error state: network failure with retry

## Acceptance Criteria
- [ ] Select tone -> generate -> output matches tone
- [ ] Copy -> email text in clipboard
- [ ] Save Draft -> appears in Library with "Email Draft" tag
- [ ] Dark mode correct

## Dependencies
- Depends on: #48 (EmailService)

## Replaces part of: #17
EOF
)"
```

---

### WEEK 7: Ads + Referral + Notifications

---

#### KEPT #9: Rewarded video ads (no change)

Small, tightly coupled AdMob integration. Service + UI are minimal and intertwined.

---

#### NEW #50: [Service] Referral: deep link generation, tracking, reward logic

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Referral: link generation, tracking, reward logic" \
  --label "P1-high,flutter,growth" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Service layer for referral system. Handles unique link generation, referral tracking via backend, reward granting (1 week Pro for both), and self-referral prevention.

## Requirements
- [ ] `ReferralService` class
- [ ] `generateReferralLink(uid)` -> String (aimaster.app/r/{code})
- [ ] `getReferralStats(uid)` -> ReferralModel (friends joined, pending, rewards earned)
- [ ] `claimReferral(referralCode)` -> processes referral on install, credits both users
- [ ] `getShareMessage()` -> pre-written share text with hook + link
- [ ] Self-referral detection: blocked via device fingerprint
- [ ] Deferred deep link handling: referral code survives Play Store install
- [ ] Milestone rewards: bonus at 3, 5, 10 referrals

## Acceptance Criteria
- [ ] Generated link is unique per user (unit test)
- [ ] Referred user's first summary -> both users get 1 week Pro (integration test)
- [ ] Self-referral blocked (unit test with same device fingerprint)
- [ ] Stats accurate: friends joined count matches actual referrals

## Dependencies
- Depends on: #1 (backend tracking), #26 (deep links), #43 (SubscriptionService for rewards)
- Blocks: #51 (Referral UI)

## Replaces part of: #10
EOF
)"
```

---

#### NEW #51: [UI] Referral: invite screen, share buttons, progress tracker

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Referral: invite screen, share buttons, progress bar, milestones" \
  --label "P1-high,flutter,design,growth" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Referral program UI: shareable invite screen with progress tracking and milestone rewards.

## Requirements
- [ ] Referral link display with "Copy Link" button
- [ ] Share buttons: WhatsApp, Twitter/X, Instagram, Generic Share
- [ ] Pre-written share message preview (editable)
- [ ] Friends tracker: "X friends joined / Y pending"
- [ ] Progress bar with milestone markers (3, 5, 10 referrals)
- [ ] Milestone reward badges
- [ ] Referral prompt surface: bottom sheet at usage limit (before hard paywall)
- [ ] "Give 1 week Pro, Get 1 week Pro" value proposition clearly displayed

## Acceptance Criteria
- [ ] Copy link -> link in clipboard, snackbar confirms
- [ ] WhatsApp share -> opens WhatsApp with pre-filled message
- [ ] Progress bar fills as referrals increase
- [ ] Referral prompt appears at usage limit context
- [ ] Dark mode correct

## Dependencies
- Depends on: #50 (ReferralService)
- Accessed from: #14 (Profile "Invite Friends" card)

## Replaces part of: #10
EOF
)"
```

---

#### KEPT #11: Push Notifications (no change)

FCM setup + scheduling is a single cohesive unit. Backend + thin client handler.

---

### WEEK 7 (continued): Churn Prevention

---

#### NEW #52: [Service] Churn Prevention: cancellation survey, winback logic, save offers

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[Service] Churn Prevention: cancellation survey, winback logic, save offers" \
  --label "P1-high,flutter,growth" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Business logic for churn prevention: cancellation survey collection, save offer eligibility, lapsed user detection, and re-engagement data.

## Requirements
- [ ] `ChurnPreventionService` class
- [ ] `submitCancellationSurvey(reason, feedback)` -> stores in Firestore
- [ ] `getSaveOffer()` -> SaveOffer? (50% off for 3 months, if eligible)
- [ ] `applySaveOffer(offerId)` -> applies discount via RevenueCat
- [ ] `isLapsedUser(lastOpenDate)` -> bool (no activity for 3+ days)
- [ ] `getWinbackData(uid)` -> "Your library has X summaries waiting"
- [ ] `getValueRecap(uid)` -> "You saved X hours with AI Master"
- [ ] Survey options: Too expensive, Not useful enough, Found alternative, Too many ads, Other

## Acceptance Criteria
- [ ] Survey stored in Firestore with uid + timestamp (integration test)
- [ ] Save offer: 50% discount applied via RevenueCat (mock test)
- [ ] Lapsed detection: 3+ days no activity -> true (unit test)
- [ ] Value recap: calculates hours saved from summary count

## Dependencies
- Depends on: #43 (SubscriptionService), #36 (LibraryService for stats)
- Blocks: #53 (Churn Prevention UI)

## Replaces part of: #25
EOF
)"
```

---

#### NEW #53: [UI] Churn Prevention: cancellation survey, save offer, re-engagement

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "[UI] Churn Prevention: cancellation survey, save offer, re-engagement interstitial" \
  --label "P1-high,flutter,design,growth" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
UI for churn prevention flows: cancellation survey modal, save offer bottom sheet, and lapsed user re-engagement screen.

## Requirements
- [ ] Cancellation survey: "Why are you leaving?" with radio options + optional text
- [ ] Save offer: "Wait! Get 50% off for 3 months" bottom sheet before confirming cancel
- [ ] Re-engagement interstitial: value recap screen for returning lapsed users
  - "Welcome back! You saved X hours with AI Master"
  - "Your library has X summaries waiting"
  - CTA: "Continue" or "Resubscribe"
- [ ] "Your trial ends tomorrow" urgency banner (triggered by push deep link)

## Acceptance Criteria
- [ ] Survey appears before cancellation completes
- [ ] Save offer: "Accept" applies discount, "No thanks" continues cancellation
- [ ] Re-engagement: shows for users returning after 7+ days absence
- [ ] Dark mode correct

## Dependencies
- Depends on: #52 (ChurnPreventionService)

## Replaces part of: #25
EOF
)"
```

---

### WEEK 8: QA + Polish + Analytics + Remaining

---

#### NEW #54: Analytics & Crashlytics: event tracking, user properties, crash reporting

```bash
gh issue create --repo tungichimedev/claude_ai_master_summary_assistant \
  --title "Analytics & Crashlytics: event tracking, user properties, crash reporting" \
  --label "P0-critical,flutter" \
  --milestone "v1.5 - Monetization MVP" \
  --body "$(cat <<'EOF'
## Summary
Cross-cutting analytics implementation. Firebase Analytics for events, user properties, and Crashlytics for crash reporting. Referenced throughout PRD but missing from issue tracker.

## Requirements
- [ ] Firebase Analytics SDK integration
- [ ] Firebase Crashlytics SDK integration
- [ ] AnalyticsService wrapper class (testable, mockable)
- [ ] Core events:
  - summary_started (input_type), summary_completed (format, duration_ms)
  - clipboard_detected, clipboard_accepted, clipboard_dismissed
  - share_intent_received, share_intent_summarized
  - expert_query_sent (expert_id), expert_response_saved
  - paywall_shown (variant, trigger), paywall_dismissed, purchase_started, purchase_completed
  - card_created (template, ratio), card_shared (platform)
  - referral_link_generated, referral_link_shared, referral_completed
  - onboarding_shown, onboarding_completed, onboarding_skipped
  - streak_milestone (count)
- [ ] User properties: tier, trial_status, streak_count, library_size, referral_count
- [ ] Screen tracking: automatic screen view logging
- [ ] Crashlytics: non-fatal error logging for API failures
- [ ] No PII in analytics events

## Acceptance Criteria
- [ ] Events appear in Firebase Analytics DebugView
- [ ] Crashes appear in Crashlytics dashboard
- [ ] User properties set correctly for segmentation
- [ ] No PII leaked in any event parameters

## Dependencies
- None (cross-cutting, can be added incrementally)
- Should be wired into all services as they are built

## PRD Reference
Section 8.1 Architecture (Firebase Analytics + Crashlytics)
EOF
)"
```

---

#### KEPT #14: Profile Screen (no change)
#### KEPT #15: Dark Mode (no change)
#### KEPT #22: Privacy/Legal (no change)
#### KEPT #23: Content Safety (no change)
#### KEPT #24: Remote Config (no change)
#### KEPT #26: Deep Linking (no change)
#### KEPT #27: Accessibility (no change)
#### KEPT #28: QA Phase (no change)

---

## Commands to Close Original Split Issues

After all new issues are created and you have their numbers, run these commands to close the originals with cross-references:

```bash
# Close #2 (Home Screen) - replaced by #37, #38, #35
gh issue comment 2 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #37 [Controller] Home, #38 [UI] Home Screen, #35 [UI] Summary Input. Closing."
gh issue close 2 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #3 (Universal Summarizer) - replaced by #33, #34, #35, #35b
gh issue comment 3 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #33 [Service] Summarizer, #34 [Controller] Summarizer, #35 [UI] Summary Input, #35b [UI] Summary Result. Closing."
gh issue close 3 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #4 (Offline Library) - replaced by #36, #39, #40
gh issue comment 4 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #36 [Service] Library, #39 [Controller] Library, #40 [UI] Library. Closing."
gh issue close 4 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #5 (RevenueCat Subscription) - replaced by #43, #44, #45
gh issue comment 5 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #43 [Service] Subscription, #44 [Controller] Subscription, #45 [UI] Paywall. Closing."
gh issue close 5 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #6 (Shareable Cards) - replaced by #46, #47
gh issue comment 6 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #46 [Service] Card Generator, #47 [UI] Card Creator. Closing."
gh issue close 6 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #8 (AI Experts) - replaced by #41, #41b, #41c
gh issue comment 8 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #41 [Service] AI Experts, #41b [Controller] AI Experts, #41c [UI] AI Experts. Closing."
gh issue close 8 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #10 (Referral) - replaced by #50, #51
gh issue comment 10 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #50 [Service] Referral, #51 [UI] Referral. Closing."
gh issue close 10 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #12 (Streak) - replaced by #42, #42b
gh issue comment 12 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #42 [Service] Streak, #42b [UI] Streak. Closing."
gh issue close 12 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #17 (Email Writing) - replaced by #48, #49
gh issue comment 17 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #48 [Service] Email Writer, #49 [UI] Email Writer. Closing."
gh issue close 17 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #21 (Firebase Auth) - replaced by #30, #31, #32
gh issue comment 21 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #30 [Service] Auth, #31 [Controller] Auth, #32 [UI] Auth. Closing."
gh issue close 21 --repo tungichimedev/claude_ai_master_summary_assistant

# Close #25 (Churn Prevention) - replaced by #52, #53
gh issue comment 25 --repo tungichimedev/claude_ai_master_summary_assistant \
  --body "Replaced by layered tickets: #52 [Service] Churn Prevention, #53 [UI] Churn Prevention. Closing."
gh issue close 25 --repo tungichimedev/claude_ai_master_summary_assistant
```

---

## Mapping Table: Old -> New Issues

| Old # | Old Title | New #s | New Titles |
|-------|-----------|--------|------------|
| #1 | Backend API | KEPT | -- |
| #2 | Home Screen | #37, #38 | [Controller] Home, [UI] Home |
| #3 | Universal Summarizer | #33, #34, #35, #35b | [Service/Controller/UI Input/UI Result] Summarizer |
| #4 | Offline Library | #36, #39, #40 | [Service/Controller/UI] Library |
| #5 | RevenueCat Subscription | #43, #44, #45 | [Service/Controller/UI] Subscription |
| #6 | Shareable Cards | #46, #47 | [Service/UI] Card Generator |
| #7 | Onboarding | KEPT | -- |
| #8 | AI Experts | #41, #41b, #41c | [Service/Controller/UI] Experts |
| #9 | Rewarded Ads | KEPT | -- |
| #10 | Referral | #50, #51 | [Service/UI] Referral |
| #11 | Push Notifications | KEPT | -- |
| #12 | Streak | #42, #42b | [Service/UI] Streak |
| #13 | ASO | KEPT | -- |
| #14 | Profile Screen | KEPT | -- |
| #15 | Dark Mode | KEPT | -- |
| #16 | User Acquisition | KEPT | -- |
| #17 | Email Writing | #48, #49 | [Service/UI] Email Writer |
| #18-20 | v2.0/v2.5 | KEPT | -- |
| #21 | Firebase Auth | #30, #31, #32 | [Service/Controller/UI] Auth |
| #22 | Privacy/Legal | KEPT | -- |
| #23 | Content Safety | KEPT | -- |
| #24 | Remote Config | KEPT | -- |
| #25 | Churn Prevention | #52, #53 | [Service/UI] Churn |
| #26 | Deep Linking | KEPT | -- |
| #27 | Accessibility | KEPT | -- |
| #28 | QA Phase | KEPT | -- |
| NEW | Models & DTOs | #29 | [Model] Core data models |
| NEW | Analytics | #54 | Analytics & Crashlytics |

---

## Dependency Graph (Critical Path)

```
Week 1:
  #29 Models ──────────────┐
  #1 Backend API ──────────┤
  #30 Auth Service ────────┤
  #31 Auth Controller ─────┤
  #32 Auth UI              │
                           │
Week 2-3:                  │
  #33 Summarizer Svc ◄────┘
  #34 Summarizer Ctrl ◄── #33 + #36
  #35 Summary Input UI ◄── #34
  #35b Summary Result UI ◄── #34
  #36 Library Svc ◄── #29
  #37 Home Controller ◄── #34 + #36 + #42
  #38 Home UI ◄── #37 + #35

Week 3-4:
  #39 Library Ctrl ◄── #36
  #40 Library UI ◄── #39
  #41 Expert Svc ◄── #1 + #29
  #41b Expert Ctrl ◄── #41
  #41c Expert UI ◄── #41b

Week 4-5:
  #42 Streak Svc ◄── #29
  #42b Streak UI ◄── #42
  #7 Onboarding ◄── #38

Week 5-6:
  #43 Subscription Svc ◄── #29 + #1
  #44 Subscription Ctrl ◄── #43
  #45 Paywall UI ◄── #44
  #46 Card Generator Svc ◄── #29
  #47 Card Creator UI ◄── #46

Week 6-7:
  #48 Email Svc ◄── #1
  #49 Email UI ◄── #48
  #50 Referral Svc ◄── #1 + #26 + #43
  #51 Referral UI ◄── #50
  #9 Rewarded Ads ◄── #44
  #52 Churn Svc ◄── #43 + #36
  #53 Churn UI ◄── #52

Week 7-8:
  #11 Push Notifications
  #54 Analytics (wire incrementally)
  #14 Profile ◄── #42b + #44
  #15 Dark Mode (cross-cutting)
  #24 Remote Config
  #23 Content Safety
  #22 Privacy/Legal
  #26 Deep Linking
  #27 Accessibility
  #28 QA Phase (final)
  #13 ASO
  #16 User Acquisition
```

---

## Final Ticket Count

| Category | Count |
|----------|-------|
| Kept as-is | 17 |
| New (split from old) | 30 |
| New (added) | 2 |
| Closed (replaced) | 11 |
| **Total open after restructuring** | **49** |
