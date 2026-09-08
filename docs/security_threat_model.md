<!--
  Author      : Ishan Tare | github.com/ISHANTARE
  Fingerprint : D7F72999BC4D94AB63560D408D69D34E
  © 2026 Ishan Tare. All rights reserved.
-->

# AURA Security Threat Model & Key Lifecycle Architecture

**Document Version:** 1.0  
**Target Architecture:** AURA v1.0.0+ (Flutter + Android Native Layer + Drift/SQLite + Google Gemini / OpenRouter)  
**Last Updated:** September 2026

---

## 1. Executive Summary & Scope

AURA is an intelligent, voice-first local productivity application combining an on-device reactive SQLite database (via Drift ORM), native Android platform integration (floating orb overlay, foreground services, broadcast receivers, and speech recognition), and direct client-side integration with Generative AI providers (Google Gemini, OpenRouter).

This document establishes the official security architecture, threat model, secrets lifecycle, and attack surface boundaries for AURA.

---

## 2. Secrets & API Key Lifecycle

### 2.1 Persistence Layer: Android Keystore & Secure Storage
* **Mechanism:** All user-provided or provisioned LLM API keys (`gemini_api_key`, `openrouter_api_key`) are persisted using `flutter_secure_storage`.
* **Android Implementation:**
  * Uses Android Keystore provider with Master Key generated via `MasterKey.Builder` (`AES256_GCM`).
  * Values are encrypted with AES-GCM and stored in private SharedPreferences (`FlutterSecureStorage`).
  * Private key material never leaves the hardware-backed Trusted Execution Environment (TEE) or StrongBox keymaster on supported devices.

### 2.2 In-Memory Lifecycle in Dart Heap
* **Heap Characteristics:**
  * Once decrypted from Secure Storage, API keys exist as Dart `String` objects on the Dart Virtual Machine (VM) managed heap.
  * Dart strings are immutable UTF-16 arrays managed by Dart's generational garbage collector (scavenger for young generation, mark-sweep-compact for old generation).
  * Dart does not support native in-place byte wiping (zeroing) of immutable `String` instances.
* **Risk Profile:**
  * On non-rooted devices: Process memory isolation enforced by the Linux kernel prevents other applications from inspecting AURA's heap.
  * On rooted devices or debug builds: An attacker with `ptrace`, `/proc/$PID/mem` read access, or memory dumping utilities could extract in-memory key strings.
* **Defensive Controls:**
  1. **Transient Exposure:** Keys are read on-demand and kept only in scoped provider references.
  2. **Zero Logging:** No logger, debug print, or crash reporter ever outputs API keys or authorization headers.
  3. **Release Obfuscation:** Release builds are compiled with `--obfuscate --split-debug-info` to hinder static binary reverse-engineering.
  4. **Wipe on Reset:** Calling `wipeAllData()` purges all keys from `flutter_secure_storage` and re-initializes Riverpod state to empty defaults.

---

## 3. Platform Channels & Android IPC Boundaries

### 3.1 Share Target Activity (`AuraShareActivity`)
* **Exposure:** Exported with `android:exported="true"` to receive `ACTION_SEND` and `ACTION_SEND_MULTIPLE` intents from other apps.
* **MIME Validation:**
  * Previously accepted wildcard `application/*`, exposing the parsing pipeline to binary crashes and exploit payloads.
  * Restricted to explicit media types: `text/*`, `image/*`, `audio/*`, `video/*`, and `application/pdf`.
  * Untrusted external URIs are resolved strictly via Android `ContentResolver` within defensive try-catch wrappers, copying streams into local application cache before database ingestion.

### 3.2 Broadcast Receivers (`AuraBootReceiver`)
* **Permissions:** Protected by `RECEIVE_BOOT_COMPLETED`.
* **Safe Service Invocation:**
  * Checks `Settings.canDrawOverlays(context)` before attempting to launch the floating orb overlay.
  * Guards against `ForegroundServiceStartNotAllowedException` on Android 12+ (API 31+).

### 3.3 Notification Payload Injection
* **Format:** Payloads use strict grammar: `route:<path>`, `item:<id>`, `alarm:<id>`.
* **Validation:**
  * Background action handlers parse payloads by prefix stripping (`startsWith`) rather than global replacement.
  * Extracted entity IDs are strictly validated using `RegExp(r'^[a-zA-Z0-9_\-]{1,64}$')` to reject delimiter injection, shell escaping, or malformed queries before touching SQLite.

---

## 4. Local Data Security & SQLite Sandboxing

### 4.1 File System Sandboxing
* Database file: `/data/data/com.aura.aura/databases/aura.sqlite`.
* Application sandbox permissions `0600` ensure only UID assigned to `com.aura.aura` can access SQLite data.
* Physical attachments (recordings, shared images) reside in the app's `app_flutter/` internal directory.

### 4.2 Data Integrity & Erasure
* **Soft Delete:** Sets `deleted_at = now()`. Items are filtered out of all views, sync jobs, and active reminder schedules. Scheduled notification alarms are immediately canceled upon soft deletion.
* **Hard Delete:** Executes in an atomic SQLite transaction (`transaction()`). Child dependencies and related logs are deleted before disk attachments are unlinked.
* **Factory Reset (`wipeAllData`):** Deletes all rows, clears secure storage, unlinks local attachments, and runs isolated maintenance without blocking UI threads.

---

## 5. Network & AI Pipeline Security

### 5.1 Transport Layer Security
* All external communication with AI backends (Google Gemini API, OpenRouter) uses TLS 1.3 with system certificate validation.
* No cleartext HTTP traffic is permitted (`android:usesCleartextTraffic="false"` in AndroidManifest).

### 5.2 Prompt Injection & Untrusted Input Handling
* **Classification Pipeline:** User speech transcripts or shared documents are treated as untrusted user payload.
* **System Prompt Isolation:** System prompts instruct Gemini models to return strict JSON matching a defined schema.
* **Parser Defense:** Responses from Gemini are parsed through robust defensive decoders (`jsonDecode`, type casting with fallback defaults) that ignore unexpected schema fields or malicious hallucinated instructions.

---

## 6. Security Threat Matrix

| Threat ID | Threat Vector | Likelihood | Impact | Applied Mitigation |
|:---|:---|:---:|:---:|:---|
| **THR-01** | API Key leakage via SharedPreferences | Low | High | Stored exclusively in Android Keystore via `flutter_secure_storage`. |
| **THR-02** | In-memory key dump on rooted device | Medium | High | Accepted residual risk for rooted environments; release binaries obfuscated. |
| **THR-03** | Malformed share payload crash | Medium | Medium | Strict MIME filtering (`application/pdf`) and safe ContentResolver streams. |
| **THR-04** | SQL/Command injection via notification tap | Low | High | Strict ID regex validation (`^[a-zA-Z0-9_\-]{1,64}$`) before DB queries. |
| **THR-05** | Phantom alarm after deletion | High | Medium | Immediate notification cancellation via `ReminderSchedulingService.cancelForItem`. |
| **THR-06** | Prompt injection via shared text | Medium | Low | Strict structured JSON schema enforcement; fallback to plain text note. |
