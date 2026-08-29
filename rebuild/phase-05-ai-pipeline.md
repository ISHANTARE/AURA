# Phase 5: AI Intent Pipeline & Offline NLP

> **Authority Document:** [`overhaul-docs/04-ai-pipeline.md`](file:///c:/Users/Admin/VIT_Projects/AURA/overhaul-docs/04-ai-pipeline.md)  
> **Status:** Complete (Verified)  

---

## Phase Overview

Phase 5 builds AURA's dual-engine intent extraction pipeline: an online LLM client supporting 6 BYOK provider presets (Gemini, Groq, NVIDIA NIM, OpenRouter, Ollama, Custom) with sliding-window rate limiting, and an offline rule-based `LocalIntentParser` ensuring 100% functionality with zero network or missing API keys.

---

## Sprint Breakdown

### Sprint 5.1: Sliding-Window RateLimiter & Injectable Clock
**Objective:** Implement `lib/features/capture/data/rate_limiter.dart` to prevent API flooding.

#### Tasks:
- [x] **Task 5.1.1: RateLimiter Class Implementation**
  - Sliding-window timestamp queue algorithm.
  - Limit: Maximum **12 requests** per rolling **60-second window**.
  - Provide `acquire()` which asynchronously awaits until oldest timestamp expires.
  - Provide `waitDuration()` calculation.
  - Support injectable `Clock` function for deterministic unit testing.
- [x] **Task 5.1.2: RateLimiter Unit Tests**
  - Implement `test/features/capture/rate_limiter_test.dart` (12 allowed immediately, 13th delayed, clock advancement).

---

### Sprint 5.2: LLM API Client & 6 BYOK Provider Presets
**Objective:** Implement `lib/features/capture/data/llm_api_datasource.dart` with robust JSON extraction and error typing.

#### Tasks:
- [x] **Task 5.2.1: Provider Presets & System Prompt**
  - Google Gemini: `https://generativelanguage.googleapis.com/v1beta/openai/` (`gemini-2.0-flash`).
  - NVIDIA NIM: `https://integrate.api.nvidia.com/v1` (`meta/llama-3.3-70b-instruct`).
  - Groq Cloud: `https://api.groq.com/openai/v1` (`llama-3.3-70b-versatile`).
  - OpenRouter: `https://openrouter.ai/api/v1` (`google/gemini-2.0-flash-001`).
  - Local LLM: `http://10.0.2.2:11434/v1` (`llama3.2`).
  - Embed verbatim system prompt with ISO-8601 date, strict JSON schema output, and workspace context.
- [x] **Task 5.2.2: JSON Extraction & Error Classification**
  - Robust extractors: Triple-backtick markdown blocks, bare JSON object extraction (`{ ... }`), prefix cleanup.
  - Typed exceptions: `LlmApiException(type: authError|rateLimit|networkError|quotaExceeded)`.
  - Empty API key or network failure triggers fallback to `LocalIntentParser`.
- [x] **Task 5.2.3: LLM Client Unit Tests**
  - Implement `test/features/capture/llm_api_datasource_test.dart`.

---

### Sprint 5.3: Offline LocalIntentParser (Deterministic Regex NLP)
**Objective:** Implement `lib/features/capture/domain/local_intent_parser.dart` for offline capture.

#### Tasks:
- [x] **Task 5.3.1: 5 Core Regex Pattern Extractors**
  - `create_alarm`: Matches `(?:set (?:an )?alarm (?:for|at) )?(\d{1,2}(?::\d{2})?\s*(?:am|pm)?)`.
  - `create_reminder`: Matches `(?:remind me (?:to|at|on) )(.+)`.
  - `create_task`: Matches task titles, workspace hints (`in workspace (\w+)`), priorities (`urgent|high priority`).
  - `add_note`: Matches `(?:note:|take a note:? )(.+)`.
  - `create_workspace`: Matches `(?:create|new) workspace (.+)`.
  - `delete_task`: Matches `(?:delete|remove) (?:task|reminder) (.+)`.
- [x] **Task 5.3.2: Date & Time Normalization**
  - Parse relative keywords: `today`, `tomorrow`, `tonight`, `next monday`, `in X hours/minutes`.
- [x] **Task 5.3.3: Local Intent Parser Unit Tests**
  - Implement `test/features/capture/local_intent_parser_test.dart` (alarm times, workspace tags, notes, unknown input).

---

### Sprint 5.4: Workspace Taxonomy Router & Action Dispatcher
**Objective:** Implement `WorkspaceRouterUseCase` and `ExecuteAiActionUseCase`.

#### Tasks:
- [x] **Task 5.4.1: 4-Tier Workspace Taxonomy Engine**
  - Tier 1: Exact Name Match (case-insensitive).
  - Tier 2: Alias / Keyword Match (e.g. "VIT" $\rightarrow$ "College").
  - Tier 3: Fuzzy Levenshtein Distance Match (threshold $\le 2$).
  - Tier 4: Fallback to General Workspace or propose "Create New Workspace".
- [x] **Task 5.4.2: ExecuteAiActionUseCase Implementation**
  - Dispatch confirmed AI intent to Drift database:
    - Create/Update `Item` (with kind and category mapping).
    - Schedule notification via `ReminderSchedulingService`.
    - Log action to `AiActionsLogs`.
- [x] **Task 5.4.3: OfflineQueueProcessor Implementation**
  - Monitor network via `ConnectivityMonitor`.
  - Drain queued actions sequentially when connection restores.
  - Enforce safeguard: **Destructive actions (delete/archive) queued offline require user re-confirmation upon reconnect**.

---

## Phase 5 Acceptance Criteria & Verification

1. `test/features/capture/rate_limiter_test.dart` passes.
2. `test/features/capture/llm_api_datasource_test.dart` passes.
3. `test/features/capture/local_intent_parser_test.dart` passes (all 6 intent regexes verified).
4. `test/features/capture/workspace_router_test.dart` passes.
