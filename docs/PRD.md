# Product Requirements Document (PRD)
# AI Master: Summary & Assistant

---

## 1. Product Overview

| Field | Detail |
|-------|--------|
| **Product Name** | AI Master: Summary & Assistant |
| **Package ID** | `com.aimaster.personal.summary.lifecoach.assistant` |
| **Developer** | Moboco |
| **Platform** | Android (7.0+) |
| **Category** | ~~Personalization~~ **Productivity** (changed per Growth Lead — Personalization is for wallpapers/launchers) |
| **Current Version** | 1.0.2 (Build 3) |
| **Initial Release** | March 19, 2026 |
| **Latest Update** | April 3, 2026 |
| **App Size** | ~36 MB |
| **Price** | Free (with planned premium subscriptions) |
| **Installs** | 10+ (early stage) |
| **Rating** | 4.0/5 (1 review) |

### Tagline
> ~~Summarize text, write emails, and get expert AI advice for work and life.~~

> **NEW (Product Team):** "Summarize any article, PDF, or link in seconds."

*Rationale (PM + Growth): The old tagline tries to say everything and says nothing. The new tagline is clear, specific, benefit-driven, and immediately understood. It positions us as a summary app, not a generic AI assistant.*

---

## 2. Market Intelligence (Research-Backed)

### 2.1 Market Size & Opportunity

| Metric | Value | Source |
|--------|-------|--------|
| GenAI mobile app revenue (2025) | $3B (273% YoY growth) | Sensor Tower |
| GenAI mobile app revenue (2026 projected) | $6B+ | Industry estimates |
| Microlearning/summary market (2026) | $3.83B | Market research |
| Microlearning/summary market (2032 projected) | $8.64B (CAGR ~12%) | Market research |
| Subscription apps = 4% of total apps but... | 45% of global app revenue | RevenueCat |

### 2.2 Competitive Landscape (Current State)

**Tier 1: Giants (DO NOT compete head-to-head)**

| App | Market Share | Price | Revenue | Weakness to Exploit |
|-----|-------------|-------|---------|---------------------|
| ChatGPT | 68% market, 63% GenAI revenue | Free/$8/$20/$200/mo | $10B ARR, $1.35B mobile | Generic (jack of all trades), quality degradation, Trustpilot 1.9/5 |
| Google Gemini | 18.2% market | Free/$7.99/$19.99/$249.99/mo | Not disclosed | Mobile lags desktop, ecosystem lock-in |
| Perplexity AI | Growing fast | Free/$20/$200/mo | $500M ARR | Aggressive upselling, hallucinated citations, Trustpilot 1.9/5 |

ChatGPT + Gemini control **86.2% of AI chatbot market**. Head-to-head competition is suicide.

**Tier 2: Vertical Players (Our real competitors)**

| App | Price | Revenue | Our Advantage |
|-----|-------|---------|---------------|
| Headway (book summaries) | $12.99/mo, $89.99/yr | $160M revenue | We add AI coaching + multi-format input |
| Blinkist (book summaries) | $14.99/mo, $99.99/yr | Significant | We summarize ANY content, not just books |
| Jasper AI (marketing) | $39-59/mo | Enterprise focus | We're consumer-friendly, mobile-first |
| Selfpause (life coach) | Freemium | Small | We're broader + better AI |
| Rocky AI (coaching) | Enterprise | Enterprise focus | We're affordable, consumer-grade |

**KEY INSIGHT: The summary app category on Google Play is fragmented with NO clear leader.** No dominant brand owns "AI summaries" the way Perplexity owns "AI search."

### 2.3 What Users Hate About Current AI Apps (Opportunity Gaps)

Based on Trustpilot reviews, app store complaints, and user forums:

| Pain Point | Apps Affected | Our Opportunity |
|------------|--------------|-----------------|
| "Jack of all trades, master of none" | ChatGPT, Gemini | Domain-specific AI experts that excel in their niche |
| Quality degradation over time | ChatGPT (major complaint) | Consistent quality via specialized prompts per domain |
| Hallucinations / fabricated info | ChatGPT, Perplexity | Summaries are grounded in source material by design |
| Price fatigue ($20/mo "for everything") | ChatGPT Plus, Perplexity Pro | Lower price, focused value: $9.99/mo |
| No offline capability | ALL major AI apps | Offline summary library (cached for later reading) |
| Poor mobile UX (web-first ports) | ChatGPT, Gemini, Perplexity | Mobile-FIRST design, built for thumb navigation |
| Data privacy concerns | ALL | Local-first storage, transparent policies |
| Aggressive upselling / ads on paid | Perplexity | Clean, respectful monetization |
| Bot-only customer support | ChatGPT, Perplexity | Human-accessible support as differentiator |

---

## 3. Vision & Problem Statement

### Vision (REVISED — Product Team Consensus)
Be the **#1 mobile-first AI summary app** — the best way to summarize any content on your phone. AI Expert coaching is a secondary feature that enhances the summary experience, not a co-equal product.

> **Product Identity: SUMMARY APP FIRST.** Experts second.
> *"We are to articles/PDFs what Headway is to books — but we summarize ANYTHING."*

### Problem Statement
Users drown in content they don't have time to read — articles, reports, PDFs, emails, research papers. Existing solutions are:
- **Too generic** — ChatGPT can summarize but doesn't save, organize, or make summaries shareable
- **Too narrow** — Headway/Blinkist only summarize books, not YOUR content
- **Too expensive** — ChatGPT Plus ($20/mo) for occasional summaries is overkill
- **Too web-first** — competitors treat mobile as afterthought
- **No offline** — 100% internet dependent, useless on commutes/flights

### Solution
AI Master is the fastest way to summarize any content on mobile — articles, PDFs, URLs — and build a personal knowledge library you can search, organize, and share. AI Expert modules (fitness, social media, cooking) provide bonus value that differentiates from pure summary apps.

### Strategic Positioning (Product Team Refined)

**We are NOT "another ChatGPT wrapper."** We are:

> **"The AI Summary App"**
> Summarize any article, PDF, or link in seconds. Save to your offline library. Share as beautiful cards. Plus bonus AI experts for fitness, cooking, social media, and more.

**Primary identity:** Summary/Knowledge tool (competes with Headway/Blinkist)
**Secondary identity:** AI Expert coaching (bonus differentiator, not core positioning)

This targets the proven $3.83B microlearning/summary market where Headway's $160M revenue proves demand — but without their "books only" limitation.

### Why This Wins (Competitive Moat)

| Moat | Why Competitors Can't Easily Copy |
|------|-----------------------------------|
| **Summary Specialist** | ChatGPT/Gemini are generalists — they won't narrow focus. Headway/Blinkist only do books. |
| **Multi-Input Summarization** | Paste text, upload PDF, share URL, Share Intent from any app — no competitor does ALL of these |
| **Offline Summary Library** | Save summaries for reading without internet — major unmet need. Creates lock-in over time. |
| **Mobile-First UX** | Summary-first home screen. Clipboard detection. Share Intent. One-thumb navigation. |
| **Shareable Summary Cards** | Beautiful Instagram/Twitter-ready summary cards with "Made with AI Master" watermark — viral growth |
| **Bonus AI Experts** | Fitness, cooking, social media experts as secondary features that no pure-summary app offers |
| **Half the Price** | $9.99/mo vs $20/mo for ChatGPT Plus — instant value proposition |
| **Privacy-Forward** | Local-first storage, no conversation training, transparent data policy |

> **PM Note on moat durability:** The offline library and shareable cards are temporary technical advantages. The real long-term moat is the **personal summary library** — once a user has 200+ organized summaries, switching cost is very high. This is a speed and execution moat, not a technology moat. Accept this and move fast.

---

## 4. Target Audience

### Primary Personas (Highest Willingness-to-Pay First)

| Persona | Age | Needs | Pain Points | Willingness to Pay | Why They Pay |
|---------|-----|-------|-------------|---------------------|--------------|
| **Busy Professional** | 25-45 | Meeting summaries, email drafting, document digests | Drowning in info, no time | HIGH ($9.99-19.99/mo) | Time = money. Saving 30 min/day worth $300+/mo |
| **Content Creator** | 20-35 | Social media strategy, writing, research summaries | Need content ideas fast, trend tracking | HIGH ($9.99-19.99/mo) | Content is their income. Better content = more revenue |
| **Self-Improvement Seeker** | 22-40 | Fitness plans, cooking, life coaching, personal growth | Multiple coaching apps cost $40+/mo combined | MEDIUM ($9.99/mo) | Consolidation savings vs. 3-4 separate apps |
| **Student / Researcher** | 18-30 | Paper summarization, study notes, writing support | Overwhelmed by reading volume | MEDIUM ($4.99-9.99/mo) | Academic performance. Would pay for time savings |

### Secondary Personas
- Home owners seeking DIY / home improvement tips
- People going through relationship transitions (dating, breakups, marriage)
- Non-native English speakers needing writing assistance

---

## 5. Feature Requirements

### 5.1 Core Features (P0 — Must Have)

#### F0: Android Share Intent (NEW — P0, Product Team Mandated)
| Item | Detail |
|------|--------|
| **Description** | Receive shared URLs/text from ANY Android app (Chrome, Twitter, Reddit, Gmail, etc.) and instantly summarize. This is the #1 UX feature missing from the original PRD. |
| **How It Works** | User sees article in Chrome -> taps Share -> selects AI Master -> app opens with summary in progress |
| **Why P0** | Eliminates copy-paste friction entirely. Reduces path-to-value from 6 steps to 2 taps. Makes app feel like a native part of Android, not a standalone silo. |
| **Effort** | 2-3 days (Android intent filter + deep link handling) |
| **Acceptance Criteria** | User shares URL from any app -> AI Master opens -> summary starts automatically -> result saved to library |

#### F0b: Clipboard Detection (NEW — P0, UX Lead Mandated)
| Item | Detail |
|------|--------|
| **Description** | On app open, detect if clipboard contains a URL or long text. Show floating banner: "Summarize [clipboard preview]?" One tap to summarize. |
| **Why P0** | Reduces path to value from 5 taps to 1 tap. Google Translate uses this pattern to great effect. |
| **Effort** | 1 day |
| **Acceptance Criteria** | User copies a URL -> opens AI Master -> sees banner with preview -> taps -> summary begins |

#### F1: Universal Summarizer (KEY DIFFERENTIATOR)
| Item | Detail |
|------|--------|
| **Description** | Summarize ANY content type into concise, actionable outputs — this is our #1 feature and main differentiator |
| **Shareable Cards** | Beautiful, branded summary cards optimized for Instagram Stories, X/Twitter, LinkedIn — viral growth mechanic |
| **Offline Library** | All summaries saved locally (Hive/Isar), searchable, organized by folders/tags — accessible without internet |
| **Why This Wins** | ChatGPT summarizes but doesn't save/organize. Headway only summarizes books. We summarize ANYTHING and build a personal knowledge library. |

**Input Methods (Phased Rollout — Tech Lead Approved):**

| Input Method | Phase | Complexity | Effort | Risk | Notes |
|-------------|-------|-----------|--------|------|-------|
| Paste text | MVP (v1.5) | Low | 2 days | Low | Straightforward API call |
| Share URL | MVP (v1.5) | Medium | 1 week | Medium | Server-side readability parser needed. JS-rendered SPAs are problematic. |
| PDF upload | MVP (v1.5) | Medium | 1 week | Low | Server-side extraction recommended. Scanned PDFs need OCR fallback. |
| DOCX upload | v2.0 | Medium | 1 week | Low | Less mature Flutter libraries; server-side extraction preferred |
| OCR (scan text) | v2.0 | Medium | 1 week | Low | Google ML Kit on-device. Accuracy varies with lighting/fonts. |
| YouTube URL | v2.5 | HIGH | 2 weeks | **HIGH** | **No stable public transcript API.** YouTube actively blocks scrapers. Third-party libs break regularly. Will require ongoing maintenance. |
| Voice memo/audio | v2.5 | HIGH | 2 weeks | Medium | Requires Whisper API ($0.006/min). Long audio needs chunking. Significant cost at scale. |

**Output Formats (Phased Rollout):**

| Output Format | Phase | Complexity | Effort | Notes |
|--------------|-------|-----------|--------|-------|
| Bullet points | MVP (v1.5) | Low | 1 day | Prompt engineering |
| Paragraph summary | MVP (v1.5) | Low | 1 day | Prompt engineering |
| Key takeaways | MVP (v1.5) | Low | 1 day | Prompt engineering |
| Action items | MVP (v1.5) | Low | 1 day | Prompt engineering |
| Shareable summary cards | MVP (v1.5) | Medium | 1 week | `RepaintBoundary` + `toImage()`. Design-heavy (9:16, 16:9, 1:1 templates). |
| Key quotes | v2.0 | Low | 1 day | Prompt engineering |
| Flashcards | v2.0 | Medium | 3 days | Structured JSON output + flashcard UI component |
| ~~Mind map~~ | **CUT** | High | 2 weeks | **No mature Flutter library. Custom canvas rendering is a time sink for unproven demand. DEFERRED INDEFINITELY.** |

**Document Size Limits (Cost-Controlled):**

| Tier | Max Input | Max Pages (PDF) | Rationale |
|------|-----------|----------------|-----------|
| Free | 2,000 words | N/A (no PDF) | Covers most articles |
| Plus | 5,000 words | 10 pages | Short reports |
| Pro | 20,000 words | 30 pages | Most business docs |
| Ultra | 50,000 words | 50 pages | Long documents (chunk-and-summarize) |

> **COST ALERT (Tech Lead):** A 100-page PDF on GPT-4o costs ~$0.80 per summary. 5 PDFs/day = $120/mo — exceeding a $12.99 subscription. Strict page limits and chunk-and-summarize strategy are MANDATORY.

| **Acceptance Criteria** | User inputs content via supported method -> selects output format -> receives accurate summary within 10s -> summary saved to library -> can share as card |
|------|--------|

#### F2: Email Writing Assistant
| Item | Detail |
|------|--------|
| **Description** | Draft, rewrite, and polish emails for professional and personal contexts |
| **Capabilities** | Compose from scratch, reply suggestions, tone adjustment (formal/casual/friendly), grammar fix |
| **Tone Options** | Professional, Casual, Friendly, Persuasive, Apologetic |
| **Acceptance Criteria** | User describes intent -> AI generates draft -> user can edit/copy/share |

#### F3: AI Chat Interface
| Item | Detail |
|------|--------|
| **Description** | Unified conversational interface to interact with all AI experts |
| **Features** | Chat history, conversation threads, context memory within session, suggested prompts |
| **Acceptance Criteria** | User can start conversation, switch experts mid-chat, view history |

### 5.2 AI Expert Modules (DOWNGRADED: P0 -> P1 per Product Team)

> **Product Team Consensus:** AI Expert modules are system prompts, not engineering effort. They are NOT core differentiators — ChatGPT does the same thing for free. Ship 2 at launch max (Social Media + Fitness), add others in v2.0. The summarizer IS the product.

> **UX Lead Mandate:** Expert responses MUST use structured output cards (formatted workout plans, ingredient lists with checkboxes, post previews) — NOT raw text in chat bubbles. This is how we differentiate from ChatGPT.

#### F4: Social Media Expert (Ship in v1.5)
- Content strategy advice for Instagram, TikTok, X, LinkedIn, YouTube
- Caption and hashtag generation
- Post scheduling suggestions
- Engagement optimization tips
- Trend analysis and content ideas
- **UX:** Responses include preview-format post mockups, not plain text

#### F5: Fitness Coach (Ship in v1.5)
- Personalized workout plans based on goals (weight loss, muscle gain, flexibility)
- Exercise form guidance and alternatives
- Nutrition advice and meal planning
- Progress tracking recommendations
- Injury prevention tips
- **UX:** Workout plans as formatted cards with exercises, sets, reps, rest times

#### F6: Expert Chef (DEFERRED to v2.0)
- Recipe suggestions based on available ingredients
- Step-by-step cooking instructions
- Dietary restriction accommodations (vegan, keto, gluten-free, etc.)
- Meal prep and planning
- Cooking technique education
- **UX:** Recipes with ingredient lists using checkboxes, step-by-step with timers

#### F7: Home & Life Improvement Advisor (DEFERRED to v2.0)
- DIY project guidance
- Home organization tips
- Budget-friendly improvement ideas
- Cleaning and maintenance schedules
- Smart home recommendations

### 5.3 ~~Relationship & Social Modules~~ — CUT ENTIRELY

> **All 3 reviewers (PM, UX, Growth) + Tech Lead agree: Remove these modules from the roadmap.**
> - Legal liability risk (marriage counseling is legally sensitive)
> - Dilutes product focus (we are a summary app, not a life coach app)
> - Not a growth driver (nobody downloads a summary app for dating advice)
> - Requires content moderation infrastructure + legal review
> - If demand emerges from user feedback, reconsider in v3.0+ with proper legal framework

### 5.4 Professional Modules (P1 — Should Have)

#### F11: Sales & Customer Service Coach
- Sales pitch preparation and role-play
- Objection handling scripts
- Customer service response templates
- Negotiation strategies
- CRM best practices

#### F12: Writing & Research Assistant
- Blog post and article drafting
- Research summarization and synthesis
- Grammar and style checking
- Citation and source suggestions
- Creative writing prompts and assistance

### 5.5 Platform Features (P0 — Must Have)

#### F13: Onboarding Flow (REVISED — UX Lead)

> **Old:** 3-4 screens + interest selection + personalization (40-60% drop-off risk)
> **New:** 1 screen + demo summary (Duolingo approach: onboarding IS the product)

- **Screen 1 (ONLY required screen):** Value prop headline + large CTA: "Summarize your first article"
- **Pre-loaded demo summary:** Show a sample article already summarized — user sees the "aha moment" immediately without typing anything
- **Skip interest selection entirely** — no personalization engine exists yet (v2.0). Infer interests from behavior.
- **Post-first-summary:** THEN ask for name/preferences (conversion is higher after value is proven)
- **Time to first value: < 20 seconds** (was 60s — UX Lead mandate: be faster than every competitor)

**The "aha moment" (PM defined):** User sees a 3,000-word article turned into 5 perfect bullet points in 6 seconds. Every design decision must minimize the time to reach this moment.

#### F14: Settings & Preferences
- Theme (light/dark/system)
- Language preferences
- Notification controls
- Data & privacy management
- Account management

#### F15: Share & Export
- Copy to clipboard
- Share via Android share sheet
- Export conversations as PDF/TXT
- Save favorite responses

### 5.6 Future Features (P2 — Nice to Have)

| Feature | Description | Priority |
|---------|-------------|----------|
| Voice Input | Speak instead of type | P2 |
| Image Analysis | Upload images for AI analysis | P2 |
| Widgets | Home screen widgets for quick access | P2 |
| Calendar Integration | Schedule suggestions synced to calendar | P2 |
| Multi-language Support | UI and AI responses in 10+ languages | P2 |
| Wear OS Companion | Quick access from smartwatch | P3 |

---

## 6. Monetization Strategy (Research-Backed)

### Market Pricing Benchmarks

| Category | Low | Standard | Premium | Ultra |
|----------|-----|----------|---------|-------|
| General AI (ChatGPT, Gemini) | $7.99/mo | $19.99/mo | $25-30/mo | $200-250/mo |
| Summary/Microlearning (Headway, Blinkist) | $7.50/mo | $12.99-14.99/mo | $139.99/yr | - |
| AI Coaching (Rocky, Selfpause) | Freemium | $9.99/mo | $19.99/mo | - |
| **Our Sweet Spot** | **$4.99/mo** | **$9.99/mo** | **$19.99/mo** | - |

### Key Monetization Insights from Research

- **Hard paywalls convert 5x better**: 10.7% download-to-paid vs. 2.1% for pure freemium (Adapty 2026)
- **Paywall screen is the #1 revenue lever**: Improving conversion from 8% to 12% = 50% revenue increase
- **Annual plans as default**: Industry standard 20% discount for annual; present annual first
- **Show paywall early**: After user experiences core value (first summary), not after prolonged free use
- **Trial with payment method**: Converts 2-3x better than no-trial

### 6.1 Free Tier (REVISED — Growth Lead + UX Lead)

> **Key Change:** 5 lifetime summaries (not 3/day). Creates urgency in first session instead of letting users coast for days without converting. This is the Headway/Blinkist model.
> **A/B Test:** Launch with both variants and measure conversion.

| Limit | Variant A (Conservative) | Variant B (Aggressive — recommended) | Rationale |
|-------|-------------------------|--------------------------------------|-----------|
| Summaries | 3 per day (resets daily) | **5 lifetime total (no reset)** | B creates urgency in Session 1. Users hit wall faster. |
| AI Expert queries | 5 per day | 3 lifetime | Keep focus on summaries |
| Summary length | Up to 2,000 words input | Up to 2,000 words input | Same |
| Output formats | Bullet points only | Bullet points + paragraph | Let users taste 2 formats |
| Offline library | ~~5 items~~ **20 items** | 20 items | PM: 5 items creates no switching cost. 20 items = real collection worth protecting. |
| Ads | Rewarded video: watch 5s ad before summary result appears (Duolingo model) | Same | UX: ads as friction drives voluntary upgrades. More effective than banner/interstitial. |
| PDF upload | No | **3 pages max** (taste it) | PM: Let free users taste PDF upload to create desire for Pro |

### 6.2 Subscription Tiers (REVISED — PM + Growth Consensus)

> **Pricing inconsistency resolved:** PRD previously said "$9.99/mo" in positioning but "$12.99/mo" in tiers. All reviewers recommend **$9.99/mo at launch** — zero brand equity means lower price to reduce friction. Raise to $12.99 once we have 500+ reviews and 4.5+ stars.

**MVP Launch (v1.5): 2 tiers only (Free + Pro)**

| Tier | Weekly | Monthly | Annual | Who It's For |
|------|--------|---------|--------|--------------|
| **Pro** (DEFAULT) | $3.99/wk | **$9.99/mo** | $59.99/yr ($5/mo) | Everyone — undercuts ChatGPT by 50%, undercuts Headway by 23% |

> **Weekly plan added (Growth Lead):** Lower commitment = higher trial starts. Weekly subscribers generate 2-3x more revenue per user (forget to cancel). Present as "most popular."

**Future Tiers (v2.0 — data-driven, add only if conversion data supports):**

| Tier | Monthly | Annual | Who It's For |
|------|---------|--------|--------------|
| **Plus** | $4.99/mo | $39.99/yr ($3.33/mo) | Students, price-sensitive — add only if $9.99 shows high price elasticity |
| **Ultra** | $19.99/mo | $149.99/yr ($12.50/mo) | Power users — add only if Pro users request more features |

### Tier Features (Tech Lead Validated)

> **MVP launches with Free + Pro only.** Plus and Ultra tiers added in v2.0 once we have conversion data.

| Feature | Free | Plus (v2.0) | Pro | Ultra (v2.0) |
|---------|------|-------------|-----|--------------|
| Daily summaries | 3 | 20 | Unlimited | Unlimited |
| Daily token budget | 5K tokens | 30K tokens | 200K tokens | 500K tokens |
| AI Expert queries | 5 | 30 | Unlimited | Unlimited |
| Input: paste text, URL | Yes | Yes | Yes | Yes |
| Input: PDF upload | No | Yes (10 pages max) | Yes (30 pages max) | Yes (50 pages max) |
| Input: OCR (scan text) | No | No | Yes (v2.0) | Yes (v2.0) |
| Input: YouTube URL | No | No | No (v2.5) | Yes (v2.5) |
| Input: Voice memo / audio | No | No | No (v2.5) | Yes (v2.5) |
| Output: bullet points, paragraph, takeaways | Yes | Yes | Yes | Yes |
| Output: flashcards | No | Yes (v2.0) | Yes (v2.0) | Yes (v2.0) |
| Output: shareable cards | No | No | Yes | Yes |
| Offline summary library | 5 items | 50 items | Unlimited | Unlimited |
| AI Experts available | 3 | All | All | All |
| AI model | GPT-4o-mini | GPT-4o-mini | GPT-4o | GPT-4o (priority) |
| Export (PDF) | No | No | Yes (v2.0) | Yes (v2.0) |
| Ads | Yes (rewarded) | No | No | No |
| Multi-device sync | No | No | No | Yes (v2.5) |

**Removed from all tiers (Tech Lead recommendation):**
- ~~Mind map output~~ — No mature Flutter library, weeks of custom work, unproven demand
- ~~Queue/Priority/Instant speed tiers~~ — Requires job queue infrastructure, overkill. All users get same speed at launch.
- ~~Custom AI expert prompts~~ — Power user feature, premature for launch
- ~~API access~~ — Premature, adds security complexity
- ~~Consumable credits IAP~~ — Adds billing complexity, defer to v2.0

### 6.3 Paywall Strategy (REVISED — Product Team)

**Paywall Trigger Points (optimized sequence):**
1. **NEVER before first completed summary** — user must experience value first
2. **After 1st successful summary** (soft, dismissible): "You just summarized 2,347 words in 6 seconds. That's 8 minutes saved. Unlock unlimited summaries."
3. **When free limit hit** (hard paywall): full paywall screen
4. **When tapping locked feature** (contextual micro-paywall): bottom sheet highlighting just that feature
5. ~~Day 2 return~~ **REMOVED** — showing paywall as "welcome back" feels punitive (UX Lead)

**Paywall Design (UX Lead — based on Calm, Headway, Duolingo best practices):**
- **Single screen, not multi-step** (each step loses users)
- Layout top-to-bottom:
  1. Bold benefit headline: "Summarize anything. Learn 10x faster."
  2. Three feature bullets with icons (NOT a comparison table — hard to read on mobile)
  3. Social proof: "Join early adopters" (do NOT claim "10,000+ users" with 10 installs — deceptive)
  4. Toggle: Monthly / Annual (annual pre-selected with "Save 50%" badge)
  5. Large CTA: "Start 7-Day Free Trial" — subtext: "Then $9.99/mo. Cancel anytime."
  6. Small "Restore Purchases" and "Terms" links
- **Show price AFTER benefits** (anchoring on value increases conversion 15-25%)
- Use Google Play's built-in free trial mechanism (no account creation needed)

**Trial duration: 7 days (was 3 days)**
> PM: 3 days is not enough to build the library lock-in the PRD depends on. 7 days lets users accumulate 15-20 summaries — enough to feel invested.

**A/B Test from Day 1 (via RevenueCat):**
- Variant A: Soft paywall after first summary + hard at limit
- Variant B: Hard paywall after onboarding with 7-day trial (Headway model)
- Variant C: Friction-based (Duolingo model) — ads before each free summary result

### 6.4 Additional Revenue Streams

| Stream | Implementation | Expected Revenue |
|--------|---------------|-----------------|
| Rewarded video ads (free tier) | Watch ad = +2 summaries | $0.02-0.05 per view, ~$3-5K/mo at scale |
| Consumable credits (IAP) | Buy 10 extra summaries for $1.99 | Impulse purchases for free users |
| B2B / Team plans | $8.99/user/mo (min 5 users) | Future Phase 4 — enterprise expansion |
| Affiliate partnerships | Recommend books/courses from summaries | Commission on purchases |

### 6.5 Revenue Projections (REVISED — Growth Lead Reality Check)

> **Previous projections were 2-3x too optimistic.** The original PRD conflated MAU with "users who see the paywall." Below are corrected numbers with optimistic, realistic, and pessimistic scenarios.

**Realistic Scenario (with $3-5K/mo paid acquisition budget):**

| Metric | Month 6 | Month 12 | Notes |
|--------|---------|----------|-------|
| Cumulative downloads | 12,000 | 60,000 | Organic + paid |
| MAU | 8,000 | 35,000 | ~50-60% of cumulative stays active |
| New installs/month | 2,500 | 8,000 | Growing via organic + paid |
| Trial start rate | 12% of new users | 15% of new users | Industry avg: 10.7% |
| Trial-to-paid conversion | 35% | 40% | Top 10%: 38.7% |
| Active paid subscribers | 500 | 2,500 | Net of churn |
| ARPU (paid, at $9.99/mo) | $9.99 | $9.99 | Single tier |
| MRR (subscriptions) | $5,000 | $25,000 | - |
| Ad Revenue (free tier) | $800 | $3,500 | Rewarded video |
| **Total Monthly Revenue** | **$5,800** | **$28,500** | - |
| **ARR** | **$69,600** | **$342,000** | - |

**Optimistic Scenario (viral moment or $10K+/mo acquisition budget):**

| Metric | Month 6 | Month 12 |
|--------|---------|----------|
| MAU | 20,000 | 80,000 |
| Paid subscribers | 1,200 | 5,500 |
| MRR | $12,000 | $55,000 |
| **ARR** | **$144,000** | **$660,000** |

**Pessimistic Scenario (no paid acquisition budget):**

| Metric | Month 6 | Month 12 |
|--------|---------|----------|
| MAU | 3,000 | 12,000 |
| Paid subscribers | 150 | 700 |
| MRR | $1,500 | $7,000 |
| **ARR** | **$18,000** | **$84,000** |

**Key milestone: 1,000 paying subscribers at $9.99/mo = $10K MRR.** This should be the Month 6 goal, not MAU. Revenue per user > user volume.

### 6.6 Unit Economics (Tech Lead + Growth Lead)

| Metric | Free User | Pro User ($9.99/mo) |
|--------|-----------|---------------------|
| Avg daily queries | 3 summaries + 2 chats | 8 summaries + 10 chats |
| AI model used | GPT-4o-mini | GPT-4o |
| Avg monthly API cost | $0.12 | $3.80 |
| Ad revenue (monthly) | $0.15 | $0 |
| Net revenue per user | +$0.03 | +$6.19 |
| **Profitable?** | **Barely (ad-supported)** | **Yes (62% margin)** |

**LTV calculation (Growth Lead):**
- At 10% monthly churn: avg subscriber lifetime = 10 months
- Gross LTV = 10 x $9.99 = $99.90
- After Google 15% cut (first year): $84.92
- After API costs ($3.80 x 10): $46.92
- After RevenueCat 1%: ~$45.92
- **Net LTV per subscriber: ~$46**
- **Target CAC: < $15** (3:1 LTV:CAC ratio)

> **Bottom line:** Free users are near break-even. Pro users at $9.99/mo are profitable at 62% margin. The business works IF we keep CAC under $15 and churn under 10%.

---

## 7. User Journeys (REVISED — Product Team)

### Journey 1: First-Time User — "The Aha Moment" (< 20 seconds)
```
1. User downloads app from Play Store
2. Sees single onboarding screen: "Summarize any article in seconds"
3. Pre-loaded demo summary is visible: a real article already summarized into 5 bullet points
4. User sees the quality and taps "Try your own"
5. Home screen: summary-first layout with large input area
6. Clipboard detected — banner: "Summarize copied article?" (user had copied a URL earlier)
7. One tap — summary begins streaming
8. Receives 5-bullet summary in 6 seconds — "aha moment"
9. Bottom bar: "Save to Library" | "Share as Card" | "Copy"
10. Soft paywall appears: "You just saved 8 minutes. Get unlimited summaries."
11. User dismisses — has 4 free summaries remaining
```

### Journey 1b: Share Intent Flow (NEW — highest-value path)
```
1. User reads article in Chrome
2. Taps Share -> selects "AI Master"
3. App opens with URL pre-filled, summary starts automatically
4. Summary appears in 8 seconds (streaming)
5. User taps "Save to Library" — summary stored offline
6. Next time user opens AI Master, sees their growing library
```

### Journey 2: Returning User — Library & Experts
```
1. User opens app (Day 3)
2. Home screen shows: "Summary of the Day" card (trending article) + recent library items
3. User taps "Summary of the Day" — reads the summary in 30 seconds
4. Scrolls down, sees "Ask an Expert" section
5. Taps "Fitness Coach" — asks for a beginner workout plan
6. Receives structured workout card (not chat bubble): exercises, sets, reps, rest times
7. Taps "Save to Library" — workout saved alongside article summaries
8. Day 4: push notification: "You have a 3-day summary streak! Keep it going."
```

### Journey 3: Premium Conversion (Corrected)
```
1. Free user has used 4 of 5 lifetime summaries
2. On 5th summary: result shows behind blur/ad — "Watch short video to unlock" or "Go Pro"
3. User watches rewarded ad — gets result. Realizes this friction will continue.
4. Day 2: hits limit. Full paywall screen appears.
5. Sees: "You've summarized 5 articles and saved 40 minutes. Imagine unlimited."
6. Toggle shows: Annual $59.99/yr (Save 50%) | Monthly $9.99/mo
7. Taps "Start 7-Day Free Trial" (annual pre-selected)
8. Google Play billing flow — one tap, no account creation
9. Day 3-7: receives value notifications: "3 new summaries saved today"
10. Day 7: trial converts automatically. User has 15+ summaries in library (lock-in).
```

### Journey 4: Referral Loop (NEW — Growth)
```
1. Pro user creates a summary card of an interesting article
2. Shares card to Instagram Story — card includes "Made with AI Master" watermark
3. Follower sees card, taps watermark link
4. Lands on Play Store, installs app
5. Pro user gets notification: "Your friend joined! You both earned 5 bonus summaries"
6. New user opens app -> demo summary -> clipboard detection -> aha moment -> conversion funnel
```

### Journey 5: Inactive User Win-Back (NEW — Growth)
```
1. User hasn't opened app in 7 days
2. Push notification: "Trending: 'How AI is changing hiring in 2026' — summarized in 60 seconds"
3. User taps notification, sees summary immediately
4. Reminded of value, starts using app again
5. Weekly stats notification: "You've saved 2.5 hours this month with AI Master"
```

---

## 8. Technical Requirements (Tech Lead Reviewed)

### 8.1 Architecture

| Layer | Component | Technology | Notes |
|-------|-----------|-----------|-------|
| **Client** | Framework | Flutter | Cross-platform ready for future iOS |
| | State Management | Riverpod (AsyncNotifier) | Suits AI streaming responses well |
| | Local Storage | Hive or Isar | Offline summary library, chat cache |
| | Local AI | Google ML Kit | On-device OCR (v2.0) |
| **Backend (CRITICAL — was missing from original PRD)** | API Layer | Firebase Cloud Functions (Node.js) | **MANDATORY.** Never call AI APIs from client — API keys would be exposed |
| | Rate Limiting | Cloud Functions + Firestore counters | Per-user daily token/query limits enforced server-side |
| | URL Scraping | Readability parser (server-side) | Extract clean text from URLs. Puppeteer for JS-rendered pages (future) |
| | Caching | Firestore with TTL | Cache popular URL summaries to reduce API costs |
| | Content Moderation | OpenAI Moderation API | Safety filter for relationship/health advice |
| | Usage Tracking | Firestore + Cloud Functions | Token budgets per user per tier per day |
| **AI** | Free / Plus tiers | GPT-4o-mini | **10-15x cheaper than GPT-4o, 80-90% quality for summaries** |
| | Pro / Ultra tiers | GPT-4o or Claude Sonnet | Advanced model for paying users |
| | Audio transcription | Whisper API (v2.5) | $0.006/min — deferred to later phase |
| **Services** | Auth | Firebase Authentication | Anonymous + email + Google Sign-In |
| | Database | Firestore (minimal) | User accounts, subscription state, usage counters ONLY. Chat/summaries stored locally. |
| | Analytics | Firebase Analytics + Crashlytics | Event tracking, crash reporting |
| | Ads | Google AdMob (rewarded video + interstitial) | Rewarded > banner (higher eCPM, better UX) |
| | Subscriptions | RevenueCat | Handles billing, trials, tier management, paywall A/B testing. 1% revenue fee. |
| | Push Notifications | Firebase Cloud Messaging | Retention nudges, trial reminders |
| | Remote Config | Firebase Remote Config | Feature flags, A/B tests, kill switches |

> **KEY ARCHITECTURE DECISION:** Local-first storage for all conversations and summaries. Firestore used ONLY for auth, subscription state, and usage tracking. This aligns with privacy-forward positioning AND reduces Firestore costs at scale.

### 8.2 AI API Cost Model (Tech Lead Analysis)

| Operation | Tokens In | Tokens Out | Cost (GPT-4o) | Cost (GPT-4o-mini) |
|-----------|----------|-----------|---------------|---------------------|
| Short article summary | ~2,000 | ~500 | $0.015 | $0.001 |
| 10-page PDF summary | ~15,000 | ~1,000 | $0.095 | $0.007 |
| 50-page PDF (chunked) | ~75,000 | ~2,000 | $0.40 | $0.03 |
| AI Expert chat query | ~1,500 | ~500 | $0.012 | $0.001 |
| Email draft | ~500 | ~300 | $0.005 | $0.0004 |
| YouTube transcript (20 min, future) | ~8,000 | ~800 | $0.050 | $0.004 |
| Audio transcription (10 min, Whisper) | — | — | $0.06 | $0.06 |

**Monthly Infrastructure Cost Projections:**

| Scenario | AI API | Firebase + Infra | RevenueCat | Total Cost | Revenue | Gross Margin |
|----------|--------|-----------------|------------|------------|---------|-------------|
| Month 6 (25K MAU) | ~$7,050 | ~$2,000 | ~$140 | **~$9,200** | $15,650 | **41%** |
| Month 12 (100K MAU) | ~$32,000 | ~$3,000 | ~$830 | **~$35,800** | $90,800 | **61%** |

**Mandatory Cost Controls (implement from Day 1):**

1. **GPT-4o-mini as default** for Free and Plus tiers (saves 10-15x vs GPT-4o)
2. **Token budgets per user per day** — not just "summary count." A 50-page PDF and a tweet should NOT count the same
3. **Cache popular URL summaries** — if 100 users summarize the same trending article, serve from cache
4. **Chunk-and-summarize for long docs** — extract key sections, summarize chunks, then meta-summarize
5. **Stream responses** — better perceived speed + ability to abort early
6. **Hard page limits per tier** — prevent cost bombs from power users

### 8.3 Non-Functional Requirements

| Requirement | Target |
|-------------|--------|
| App cold start | < 3 seconds |
| AI response time | < 10 seconds (95th percentile) |
| Crash-free rate | > 99.5% |
| ANR rate | < 0.5% |
| Offline support | Full summary library + cached conversations accessible offline. New requests queued. |
| Min Android version | 7.0 (API 24) |
| APK size | < 40 MB |
| Battery impact | < 3% per 30-min active session |

### 8.4 Data & Privacy

- All conversations and summaries stored locally by default (Hive/Isar)
- Cloud sync opt-in only (Ultra tier, future)
- User data encrypted at rest and in transit (TLS 1.3)
- AI API calls go through our backend — user data never sent directly to OpenAI/Anthropic from client
- No conversation data shared with third parties or used for model training
- GDPR and CCPA compliant
- Data deletion available on request (local wipe + server-side deletion)
- Privacy policy and terms of service accessible in-app
- Google Play Data Safety section fully disclosed

### 8.5 Backend Security Requirements (NEW — Tech Lead Mandated)

| Requirement | Implementation |
|-------------|---------------|
| API key protection | All AI API calls through Cloud Functions. No API keys in client code. |
| Rate limiting | Server-side enforcement per authenticated user. Unauthenticated users blocked. |
| Abuse prevention | Device fingerprint + Firebase Auth. Reinstalling app does NOT reset limits. |
| Input validation | Sanitize all user inputs before sending to AI API. Max input size enforced server-side. |
| Content safety | OpenAI Moderation API on all outputs. Flag/block harmful content. |
| DDoS protection | Cloud Functions auto-scaling + Firebase App Check to verify legitimate client. |

---

## 9. Success Metrics & KPIs (REVISED — Growth Lead Reality Check)

### Acquisition
| Metric | Target (Month 6) | Target (Month 12) | AI App Benchmark |
|--------|------|------|------|
| Cumulative Downloads | 12,000 | 60,000 | - |
| MAU | 8,000 | 35,000 | - |
| Organic Install Rate | 40% | 55% | - |
| Cost Per Install (paid) | < $2.00 | < $1.50 | AI apps: $0.80-3.00 |
| CAC (cost per paying subscriber) | < $15 | < $12 | Target 3:1 LTV:CAC |

### Engagement
| Metric | Target | Notes |
|--------|--------|-------|
| DAU/MAU ratio | > 20% | 25% was aggressive; 20% is realistic for utility apps |
| Avg. sessions per day | 1.5 | 2.5 was optimistic for a summary tool |
| Avg. session duration | 3 minutes | Summary = quick in/out, not long sessions |
| Summaries per user per day (active) | 2-3 | Core engagement metric |
| Time to first summary (new user) | < 20 seconds | UX Lead mandate |

### Retention (Growth Lead Adjusted)
| Metric | Target | AI App Average | Notes |
|--------|--------|---------------|-------|
| Day 1 retention | > 35% | 25-35% | ~~45%~~ was top-1% territory |
| Day 7 retention | > 18% | 12-18% | ~~25%~~ Achievable with good push notifications |
| Day 30 retention | > 10% | 6-10% | ~~15%~~ 15% would be exceptional. Target 10-12%. |

### Revenue
| Metric | Target | Notes |
|--------|--------|-------|
| Trial start rate | 12% of new users | Industry avg hard paywall: 10.7% |
| Trial-to-paid conversion | 35% | Top 10%: 38.7% |
| Monthly churn (premium) | < 10% | Avg AI app: 10-15% |
| LTV (premium user) | > $46 | 10 months x $9.99 - costs |
| **Key milestone** | **1,000 paid subscribers by Month 6** | $10K MRR = proof of business |

---

## 10. Competitive Analysis (Deep Dive)

### Direct Competitors & Positioning Map

| App | Category | Price | Revenue | Rating | Key Strength | Key Weakness | How We Win |
|-----|----------|-------|---------|--------|-------------|-------------|------------|
| **ChatGPT** | General AI | $20/mo | $10B ARR | 4.6 Android | Brand, 68% market share | Generic, Trustpilot 1.9/5, quality degradation | Specialized experts, half the price, mobile-first |
| **Gemini** | General AI | $19.99/mo | Not disclosed | ~4.5 | Google ecosystem, 750M MAU | Mobile lags desktop, ecosystem lock-in | Standalone, no Google dependency, better mobile UX |
| **Perplexity** | AI Search | $20/mo | $500M ARR | Mixed | Citations, research focus | Aggressive upselling, hallucinated sources, ads on paid | Honest pricing, no ads on paid, grounded summaries |
| **Headway** | Book Summaries | $12.99/mo | $160M revenue | 4.7 | Book summaries, microlearning | ONLY books, no AI chat, no coaching | Summarize anything + AI coaching |
| **Blinkist** | Book Summaries | $14.99/mo | Significant | 4.5 | Audio summaries, large library | ONLY books, stale content model | Real-time AI summaries of any content |
| **Selfpause** | AI Life Coach | Freemium | Small | 4.0 | Affirmations, mindset | Limited features, no summarization | 10x broader, better AI, summary+coaching combo |
| **Rocky AI** | AI Coaching | Enterprise | Enterprise | 4.2 | Professional coaching | Expensive, enterprise-only | Consumer-friendly, affordable |
| **Jasper AI** | Marketing AI | $39-59/mo | Enterprise | 4.2 G2 | Marketing content | No mobile app, very expensive | Mobile-first, 3-6x cheaper |

### Competitive Positioning Statement (REVISED)

> **"AI Master is the fastest way to summarize any article, PDF, or link on your phone — and save it to your personal knowledge library. At $9.99/month, it's half the price of ChatGPT Plus with a better mobile experience for summaries."**

### Why We're NOT a "ChatGPT Wrapper"

| ChatGPT Wrapper (bad) | AI Master (our approach) |
|------------------------|--------------------------|
| Generic chat with OpenAI API | Domain-tuned experts with structured outputs |
| No unique data or format | Shareable summary cards, offline library, flashcards |
| Same UX as ChatGPT website | Mobile-first UX designed for one-thumb use |
| No retention hooks | Summary library, streaks, daily growth plans |
| Competes on AI model quality (unwinnable) | Competes on UX, format, specialization, price |

### Features That Command Premium Pricing ($15-30/mo range)

Based on what users actually pay for across top AI apps:

| Feature | Who Charges For It | Can We Offer It? |
|---------|-------------------|------------------|
| Access to frontier AI models | ChatGPT ($20), Gemini ($20), Claude ($20) | Yes (Ultra tier) |
| Deep research with citations | Perplexity ($20) | Yes (via summary sourcing) |
| File/document analysis | ChatGPT Plus, Gemini Pro | Yes (Pro tier) |
| Priority response speed | Most AI apps | Yes (Pro/Ultra) |
| Memory & personalization | ChatGPT Plus | Yes (learns preferences across domains) |
| Multi-modal input (voice, image, scan) | ChatGPT Plus, Gemini Pro | Yes (Pro tier) |
| Offline access | NOBODY offers this well | YES — major differentiator |
| Beautiful shareable outputs | NOBODY offers this | YES — viral growth mechanic |
| Structured coaching programs | Rocky ($enterprise) | Yes (Pro tier at consumer price) |

---

## 11. Differentiation Playbook (How We Win)

### The 8 Things We Do That Nobody Else Does

| # | Differentiator | What It Means | Competitor Gap |
|---|---------------|---------------|----------------|
| 1 | **Universal Summarizer** | Summarize articles, PDFs, YouTube, podcasts, voice memos, scanned text — ALL in one app | ChatGPT: text only. Headway: books only. |
| 2 | **Offline Summary Library** | Every summary saved locally, searchable, organized by tags/folders. Read without internet. | NO major AI app offers meaningful offline. |
| 3 | **Shareable Summary Cards** | One-tap export as beautiful cards for Instagram, X, LinkedIn. Branded, viral. | Nobody does this. Free marketing from users. |
| 4 | **Domain-Expert AI** | Each expert (fitness, chef, social media, etc.) uses tuned system prompts, structured outputs, domain knowledge | ChatGPT: generic. One prompt fits all. |
| 5 | **Mobile-First UX** | Designed for thumb navigation, quick actions, swipe interactions. Not a web port. | ChatGPT, Gemini, Perplexity: all web-first ports. |
| 6 | **Summary + Coaching Combo** | Summarize a self-help book, then get AI coaching based on the content. Learn + Apply. | Headway: summarize only. Selfpause: coach only. Nobody combines. |
| 7 | **Half the Price** | Pro at $9.99/mo vs ChatGPT Plus at $20/mo. 50% cheaper for the summary use case. | Price-sensitive users have no good option today. |
| 8 | **Privacy-Forward** | Local-first storage, no conversation training, transparent data policy. | ChatGPT, Gemini: train on conversations by default. |

### Growth Flywheel

```
User summarizes content
    -> Saves to personal library (retention)
    -> Shares as beautiful card on social (acquisition)
    -> Friends see card, download app (viral loop)
    -> New user summarizes content
    -> ...repeat
```

This flywheel is UNIQUE to us. ChatGPT has no built-in sharing/viral mechanic.

---

## 12. User Acquisition Strategy (NEW — Growth Lead)

> **This was the #1 gap in the PRD.** "Shareable cards" is a growth feature, not an acquisition strategy. You cannot rely on viral mechanics from an app with 10 users.

### 12.1 Phase A: Foundation (Weeks 1-4 post-launch)

| Tactic | Cost | Expected Impact | Effort |
|--------|------|----------------|--------|
| **Fix ASO:** Move to Productivity category, keyword-optimize title/description/screenshots | $0 | 3-5x organic discovery | 1 day |
| **Launch on Product Hunt** with demo GIF: "AI that summarizes anything in 10 seconds" | $0 | 500-2,000 installs in first week | 2 days prep |
| **Post on Reddit:** r/productivity, r/GetStudying, r/AItools, r/androidapps — genuine "I built this" posts | $0 | 100-300 installs per viral post | 1 hour each |
| **Submit to 20 app directories:** AlternativeTo, SaaSHub, BetaList, SideProjectors, etc. | $0 | 200-500 installs total | 2 days |
| **Create TikTok/Instagram Reels account** — 1 video/day showing before/after summarization | $0 | 100-500 installs/week once a video hits | 1 hr/day |

### 12.2 Phase B: Paid + Influencer (Weeks 5-8)

| Tactic | Cost | Expected Impact | Notes |
|--------|------|----------------|-------|
| **Google UAC** targeting "summarize article app", "AI summary", "PDF summarizer" | $30-50/day ($900-1,500/mo) | 15-30 installs/day at $1-2 CPI | Our best paid channel |
| **5 TikTok-style ad creatives** — before/after: 30-page PDF to 5 bullets in 10 seconds | $200-500 production | Powers both organic + paid | UGC style converts best |
| **5-10 micro-influencers** (10K-50K followers in productivity niche) | Free Pro lifetime or $200-500 each | 200-500 installs per influencer | YouTube and TikTok |
| **Meta ads** targeting Headway/Blinkist users (interest-based) | $500-1,000/mo | Testing phase | Scale if ROAS > 2x |

### 12.3 Phase C: Scale (Weeks 9-12)

| Tactic | Cost | Expected Impact |
|--------|------|----------------|
| Double budget on best-performing paid channel | $3-5K/mo | Scale what works |
| **Launch referral program** — "Invite friend, both get 5 Pro summaries" | 3-5 days dev | 15-25% of organic growth |
| **Free web tool** at aimaster.app/summarize — summarize 1 article free, then prompt download | 2-3 days dev | 200-1,000 installs/mo from SEO |
| **Email outreach** to 50 "best AI apps" / "best productivity apps" list authors | $0 | 3-5 inclusions, 100-300 installs each |
| **Podcast sponsorship** (productivity/business podcasts) | $500-1,000 per read | Test 2-3 podcasts |

### 12.4 ASO Recommendations (Growth Lead)

| Element | Current | Recommended |
|---------|---------|-------------|
| **App name** | AI Master: Summary & Assistant | **"AI Master - Summarize Anything in Seconds"** (benefit in title) |
| **Category** | Personalization | **Productivity** (primary) + Education (secondary) |
| **Short description** | Unknown | "Summarize articles, PDFs, and links instantly. Save offline. Share as beautiful cards." |
| **Screenshot 1** | Unknown | "Summarize Any Article in 10 Seconds" — before/after |
| **Screenshot 2** | Unknown | "Your Personal AI Experts" — expert grid |
| **Screenshot 3** | Unknown | "Save & Share Beautiful Summaries" — library + card |
| **Target keywords** | None | AI summary, summarize article, PDF summarizer, article summarizer, book summary app, ChatGPT alternative |

### 12.5 Acquisition Budget (First 90 Days)

| Item | Budget | Notes |
|------|--------|-------|
| Google UAC | $2,700-4,500 | $30-50/day |
| Meta Ads | $1,500-3,000 | Testing |
| Influencers | $1,000-3,000 | 5-10 micro-influencers |
| Content production (ad creatives) | $500 | 5 TikTok-style videos |
| **Total** | **$5,700-$11,000** | Target: 3,000-6,000 installs from paid |

---

## 13. UX Architecture (NEW — UX Lead)

### 13.1 App Structure

**Summary-first home screen.** NOT an AI experts grid.

```
Bottom Tab Bar (4 tabs):
  [Summarize]  [Experts]  [Library]  [Profile]
       ^           ^          ^          ^
     HOME      Secondary   THE MOAT   Settings
```

### 13.2 Home Screen ("Summarize" tab)

```
+----------------------------------+
|  [clipboard banner if detected]  |
|  "Summarize copied article?"     |
+----------------------------------+
|                                  |
|  [Large input area]              |
|  "Paste, share, or upload..."    |
|  [Text] [URL] [PDF]  <- chips   |
|                                  |
+----------------------------------+
|  Summary of the Day              |
|  [Trending article summary card] |
+----------------------------------+
|  Recent Summaries                |
|  [Card 1] [Card 2] [Card 3]     |
+----------------------------------+
```

### 13.3 Summary Result Screen

```
+----------------------------------+
|  [Source title + favicon]        |
|  2,347 words -> 5 key points    |
+----------------------------------+
|                                  |
|  [Output format chips]           |
|  Bullets | Paragraph | Takeaways |
|  (swipe to switch)               |
|                                  |
|  * Key point 1                   |
|  * Key point 2                   |
|  * Key point 3                   |
|  * Key point 4                   |
|  * Key point 5                   |
|                                  |
+----------------------------------+
|  [Save] [Share] [Card] [Copy]   |
+----------------------------------+
```

### 13.4 Key Interactions

| Gesture | Where | Action |
|---------|-------|--------|
| Swipe left on library card | Library | Delete / archive |
| Swipe right on library card | Library | Share |
| Long-press on summary text | Summary view | Copy selection / create card from selection |
| Pull down on home | Home | Refresh / new input |
| Double-tap on summary | Summary view | Bookmark / favorite |
| Swipe between format chips | Summary result | Switch bullet/paragraph/takeaways |

### 13.5 Animation & Micro-interactions

- **Summary generation:** Text streams in with slight fade-in per line + subtle pulse on AI avatar
- **Save to library:** Card animates (shrink + fly) toward Library tab icon. Tab bounces to confirm.
- **Streak counter:** Number increments with satisfying pop/scale animation
- **Pull-to-refresh:** Custom animation with app logo, not default Material spinner
- **Haptic feedback:** Light haptic on save, share, card export. Medium on streak milestone.
- **Respect "reduce motion" setting** for users with vestibular disorders

### 13.6 Retention Features (UX-Defined)

| Feature | Priority | Effort | Impact |
|---------|----------|--------|--------|
| **Summary of the Day** push notification (trending article) | P0 (v1.5) | 2 days | #1 retention driver. Costs nearly nothing (1 cached API call/day). |
| **Summary streak** (consecutive days with a summary) | P1 (v1.5) | 2 days | Duolingo proved streaks work. Show on home screen. |
| **Weekly stats notification** ("You saved 3.5 hours this week") | P1 (v1.5) | 1 day | Reinforces subscription value at renewal time |
| **Cross-expert referrals** ("Want a meal plan? Ask the Chef") | P1 (v2.0) | 1 day | Drives multi-expert usage |
| **Library synthesis** ("You summarized 5 articles on productivity. Want a combined summary?") | P2 (v2.0) | 1 week | Creates NEW value from existing content |
| **Quick review mode** (swipe through saved summaries as flashcards) | P2 (v2.0) | 1 week | Makes library a study tool, not just storage |

---

## 15. Risks & Mitigations (Product + Technical)

### Product Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| "ChatGPT wrapper" perception | High | High | Ship unique features first (offline library, cards, multi-input). Never position as "chat with AI" |
| Low retention after novelty | Medium | High | Summary library creates lock-in (like photos in Google Photos). Streaks, daily growth plans, push notifications |
| Play Store rejection | Medium | High | Follow Google AI content policies, add disclaimers, content filtering |
| Competitor copies features | High | Medium | Move fast, build library lock-in, community. First-mover in "summary + coaching" niche |
| Harmful AI advice (fitness, relationships) | Medium | High | Disclaimers, safety filters, report mechanism. Defer relationship modules until legal review. |
| Price war from big players | Medium | Medium | Compete on specialization and UX, not price alone. Value is format + organization, not raw AI power |

### Technical Risks (Tech Lead Identified)

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **AI API costs exceed revenue** | High | Critical | GPT-4o-mini as default (10-15x cheaper). Token budgets per tier. Cache popular summaries. Chunk long docs. Hard page limits. |
| **100-page PDF cost bomb** | High | High | Strict page limits per tier (max 50 pages Ultra). Chunk-and-summarize strategy. Never process full doc in single API call. |
| **No backend = exposed API keys** | Certain (if not built) | Critical | Cloud Functions backend is Week 1-2 priority. MANDATORY before any other feature. |
| **YouTube transcript extraction breaks** | Very High | Medium | Defer to v2.5. Use robust third-party service, not scraping. Build with fallback (manual paste). |
| **Free tier abuse (reinstall bypass)** | High | Medium | Firebase Auth + device fingerprint. Server-side rate limiting per authenticated user. |
| **RevenueCat 3-tier complexity** | Medium | Medium | Launch with 2 tiers only (Free + Pro). Add Plus/Ultra in v2.0 with conversion data. |
| **Offline sync conflicts (multi-device)** | Medium | Medium | Defer multi-device sync to v2.5 (Ultra only). Local-first with no sync at launch. |
| **User data breach** | Low | Critical | Local-first architecture, E2E encryption, security audits, minimal server-side data, Firebase App Check |

---

## 14. Release Roadmap (Tech Lead + Product Team Validated)

### Phase 1: MVP v1.0 (SHIPPED — March 2026)
- [x] Core chat interface
- [x] Text summarizer (paste only)
- [x] Email writing assistant
- [x] Social Media Expert
- [x] Fitness Coach
- [x] Expert Chef
- [x] Home & Life Improvement
- [x] Basic onboarding

### Phase 2: Monetization MVP v1.5 (8 weeks — Target: June 2026)

**Critical Path (Week-by-Week — Updated with Product Team features):**

| Week | Deliverable | Effort | Team |
|------|------------|--------|------|
| 1-2 | **Backend API (Cloud Functions)** — auth, rate limiting, AI proxy, usage tracking, caching | 1.5 weeks | Backend dev |
| 1 | Firebase Auth (anonymous + email + Google Sign-In) | 2 days | Flutter dev |
| 2-3 | **Summary-first home screen** + chat interface (streaming, persistence) | 1.5 weeks | Flutter dev |
| 2 | **Android Share Intent** + **Clipboard detection** | 3 days | Flutter dev |
| 3-4 | **URL summarizer** (server-side readability parser) | 1 week | Full stack |
| 4 | 2 AI Expert modules (Social Media + Fitness) — tuned prompts, structured output cards | 4 days | Flutter dev + prompt eng |
| 4-5 | **Offline summary library** (Hive/Isar, folders, tags, search, 20-item free limit) | 1 week | Flutter dev |
| 5 | **1-screen onboarding + demo summary** + Summary streak counter | 2 days | Flutter dev |
| 5-6 | **RevenueCat subscription (Free + Pro)** + paywall UI (3 A/B variants) + 7-day trial | 1.5 weeks | Flutter dev |
| 6 | Share (copy, share sheet) + **shareable summary cards** with watermark | 1 week | Flutter dev |
| 7 | **PDF upload** + rewarded video ads (AdMob) + **Summary of the Day** notification | 1 week | Full stack |
| 7 | **Referral program** (invite link + reward logic) | 3 days | Full stack |
| 8 | QA, polish, performance, `flutter analyze`, **ASO optimization**, store listing update | 1 week | All |

**What's IN v1.5 (Product Team Final):**
- [ ] Backend API with rate limiting and token budgets
- [ ] **Android Share Intent** (NEW — P0, share URL from any app to summarize)
- [ ] **Clipboard detection** (NEW — P0, auto-detect URL/text on app open)
- [ ] URL summarizer (server-side)
- [ ] PDF upload (up to 30 pages for Pro, 3 pages free)
- [ ] Offline summary library with 20-item free limit (THE moat)
- [ ] Shareable summary cards with "Made with AI Master" watermark (viral mechanic)
- [ ] **Summary-first home screen** (NOT expert grid — UX Lead mandate)
- [ ] **1-screen onboarding + demo summary** (was 3-4 screens)
- [ ] Streaming AI responses
- [ ] RevenueCat subscription (Free + Pro at $9.99/mo + $3.99/wk)
- [ ] Optimized paywall with A/B testing (3 variants)
- [ ] **7-day free trial** (was 3-day)
- [ ] Rewarded video ads before free summary results (Duolingo model)
- [ ] **Summary of the Day** push notification (P0 retention feature)
- [ ] **Summary streak** counter on home screen
- [ ] 2 AI Expert modules only: Social Media + Fitness (was 4)
- [ ] **Referral program** — "Invite friend, both get 5 Pro summaries"
- [ ] GPT-4o-mini for free, GPT-4o for Pro
- [ ] Token budget enforcement
- [ ] **ASO optimization** — new category, keywords, screenshots

**What's CUT from v1.5 (deferred or removed):**
- ~~YouTube URL summarization~~ — unreliable transcript API (v2.5)
- ~~Voice memo / audio input~~ — Whisper cost + complexity (v2.5)
- ~~OCR / scan text~~ — nice-to-have (v2.0)
- ~~3-tier subscription~~ — launch Free + Pro only
- ~~Relationship modules (F8-F10)~~ — **CUT ENTIRELY** (all reviewers)
- ~~Mind map output~~ — CUT indefinitely
- ~~Queue/Priority speed tiers~~ — removed
- ~~Expert Chef + Home Improvement at launch~~ — deferred to v2.0 (ship 2 experts max)
- ~~DOCX upload~~ — PDF covers 95% of use cases (Growth Lead)

### Phase 3: Expand & Retain v2.0 (Target: September 2026)
- [ ] Plus and Ultra subscription tiers (data-driven pricing)
- [ ] OCR / scan text input (Google ML Kit)
- [ ] Flashcard output format
- [ ] DOCX upload support
- [ ] Sales & Customer Service Coach module
- [ ] Writing & Research Assistant module
- [ ] Export to PDF
- [ ] Personalization engine (learns preferences)
- [ ] Multi-language support (top 5 languages)
- [ ] Dating & Social Coach (after legal review)
- [ ] Consumable credits IAP
- [ ] Widgets for home screen

### Phase 4: Multi-Input v2.5 (Target: December 2026)
- [ ] YouTube URL summarization (with robust third-party service)
- [ ] Voice memo / audio input (Whisper API)
- [ ] Image analysis (upload photos for advice)
- [ ] Multi-device sync (Ultra tier)
- [ ] Relationship Support module (after legal review)
- [ ] Marriage Counseling module (after legal review)
- [ ] Advanced caching layer (popular content)

### Phase 5: Scale v3.0 (Target: March 2027)
- [ ] iOS launch
- [ ] Web companion app
- [ ] Calendar integration
- [ ] B2B / Team plans
- [ ] Community features (share tips, templates)
- [ ] API for third-party integrations

---

## 16. Acceptance Criteria (Definition of Done)

For any feature to be considered complete:

1. All functional requirements implemented and tested
2. All 12 UI states handled (loading, empty, error, success, etc.)
3. Works on Android 7.0+ (tested on API 24, 28, 31, 34)
4. Dark mode supported
5. Accessibility: TalkBack compatible, minimum touch targets 48dp
6. Performance: no jank (60fps), response < 10s
7. Analytics events tracked
8. No `flutter analyze` warnings
9. Unit test coverage > 80% for business logic
10. Manual QA passed on 3+ device form factors

---

## 17. Open Questions

### Resolved (by Tech Lead + Product Team Reviews)

| # | Question | Decision | Decided By |
|---|----------|----------|------------|
| 1 | Which AI provider? | GPT-4o-mini (free) + GPT-4o (pro) | Tech Lead |
| 2 | Daily limit: query count or token-based? | **Token-based budgets** | Tech Lead |
| 3 | iOS simultaneously? | Android-first | Product |
| 4 | Free trial duration? | **7-day free trial** (was 3-day) | PM + Growth |
| 5 | How many subscription tiers at launch? | **2 only (Free + Pro)** | Tech Lead + PM |
| 6 | Mind map output? | **Cut indefinitely** | Tech Lead |
| 7 | YouTube URL at launch? | **Deferred to v2.5** | Tech Lead |
| 8 | Launch price? | **$9.99/mo** (was $12.99) | PM + Growth |
| 9 | Product identity? | **Summary app first**, experts second | All 3 reviewers |
| 10 | Home screen pattern? | **Summary-first** (not expert grid) | UX Lead |
| 11 | Onboarding length? | **1 screen + demo** (was 3-4 screens) | UX Lead |
| 12 | Free tier model? | **A/B test:** 3/day vs 5 lifetime | Growth Lead |
| 13 | Free library limit? | **20 items** (was 5) | PM |
| 14 | Play Store category? | **Productivity** (was Personalization) | Growth Lead |
| 15 | Relationship modules (F8-F10)? | **CUT ENTIRELY** | All reviewers |
| 16 | How many AI experts at launch? | **2 max** (Social Media + Fitness) | PM + Growth |
| 17 | Social proof on paywall? | **"Join early adopters"** (never claim fake user count) | PM |

### Still Open

| # | Question | Owner | Status |
|---|----------|-------|--------|
| 1 | Localization priority languages? | Product | Open |
| 2 | Backend hosting: Cloud Functions vs dedicated server? | Tech Lead | Leaning Cloud Functions |
| 3 | Which readability parser for URL extraction? | Tech Lead | Open — needs evaluation |
| 4 | Cache TTL for popular URL summaries? | Tech Lead | Open |
| 5 | Firebase App Check — which attestation provider? | Tech Lead | Open |
| 6 | Whisper API vs Google Speech-to-Text for audio (v2.5)? | Tech Lead | Open |
| 7 | On-device summarization with Gemma Nano? | Tech Lead | Future (v3.0) |
| 8 | Paid acquisition budget — how much can we allocate for first 90 days? | Founder | Open — Growth Lead recommends $5-11K |
| 9 | Weekly plan pricing — $2.99 or $3.99? | Growth | Needs A/B test |
| 10 | Should we build a free web summary tool for SEO? | Growth | Open — 2-3 days dev, high organic potential |
| 11 | "Summary of the Day" — curate manually or auto-select trending articles? | Product + Tech | Open |

---

---

## 18. Sources & References

- [ChatGPT Pricing 2026 — Fritz AI](https://fritz.ai/chatgpt-pricing/)
- [ChatGPT Statistics 2026 — DemandSage](https://www.demandsage.com/chatgpt-statistics/)
- [Google Gemini Statistics 2026 — GetPanto](https://www.getpanto.ai/blog/google-gemini-statistics)
- [Perplexity AI Statistics 2026 — Business of Apps](https://www.businessofapps.com/data/perplexity-ai-statistics/)
- [AI App Revenue Statistics 2026 — Business of Apps](https://www.businessofapps.com/data/ai-app-market)
- [State of AI Apps 2025 — Sensor Tower](https://sensortower.com/blog/state-of-ai-apps-market-overview-2025)
- [ARPU Benchmarks AI Chatbot Apps — Thrad](https://www.thrad.ai/content/arpu-benchmarks-for-ai-chatbot-apps)
- [State of Subscription Apps 2025 — RevenueCat](https://www.revenuecat.com/state-of-subscription-apps-2025/)
- [In-App Subscription Benchmarks 2026 — Adapty](https://adapty.io/state-of-in-app-subscriptions-report/)
- [Headway Revenue Model — Break-Even Point Calculator](https://breakevenpointcalculator.com/how-does-headway-make-money-revenue-model-explained/)
- [Blinkist Pricing 2026 — BeFreed](https://www.befreed.ai/blog/blinkist-pricing-2026)
- [AI Chatbot Market Share 2026 — Vertu](https://vertu.com/lifestyle/ai-chatbot-market-share-2026-chatgpt-drops-to-68-as-google-gemini-surges-to-18-2)

---

*Document Version: 4.0 (Full Team Review)*
*Author: Product Owner*
*Reviewed By: Market Researcher, Tech Lead, Product Manager, UX Lead, Growth Lead*
*Last Updated: May 14, 2026*
*Status: APPROVED WITH REVISIONS — Ready for implementation*

**Review Verdicts:**
| Reviewer | Score | Verdict |
|----------|-------|---------|
| Market Researcher | N/A | Market opportunity validated |
| Tech Lead | 7/10 | GO WITH CHANGES |
| Product Manager | 5/10 -> 7/10 (after revisions) | REVISE -> APPROVED |
| UX Lead | N/A | REVISE -> APPROVED (with summary-first identity) |
| Growth Lead | N/A | REVISE -> APPROVED (with acquisition strategy) |

**Key decisions made:**
1. Product identity: Summary app first, experts second
2. Price: $9.99/mo (resolved $12.99 inconsistency)
3. Home screen: Summary-first, not expert grid
4. Onboarding: 1 screen + demo (was 3-4)
5. Free tier: A/B test 3/day vs 5 lifetime
6. Trial: 7 days (was 3)
7. Relationship modules: CUT entirely
8. AI experts at launch: 2 (was 4)
9. Acquisition strategy: $5-11K budget for first 90 days
10. Revenue target: $28.5K MRR Month 12 (realistic) vs $90.8K (previous, optimistic)
