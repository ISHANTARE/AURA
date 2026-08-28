# Privacy Policy for AURA (AI-Unified Reality Assistant)

**Last Updated:** August 28, 2026

## 1. Overview & Privacy-First Philosophy
AURA ("we", "our", or "the app") is designed from the ground up with an **offline-first and user-sovereign architecture**. Your personal data, schedule, notes, alarms, and workspaces belong entirely to you.

---

## 2. Information We Collect and How It Is Used

### A. On-Device Local Data (SQLite / Drift Database)
- **Workspaces, Tasks, Notes, and Alarms:** All entries, deadlines, priorities, and recurrence rules are stored locally on your physical device using an encrypted local SQLite database. They are **never uploaded to any proprietary AURA cloud server**.
- **User Preferences:** Display name, active accent theme, sound selections, and notification hours are stored strictly in local device storage (`SharedPreferences`).

### B. Voice Input & Speech-to-Text Processing
- When you activate voice capture via the floating orb, Quick Settings tile, or in-app mic button, audio is processed locally using the standard Android on-device Speech Recognizer.
- Raw audio recordings are **not recorded to disk, retained, or transmitted to third-party ad networks**.

### C. Large Language Model (LLM) Integration
- AURA allows you to connect an API key from third-party AI providers (e.g. Google Gemini, NVIDIA NIM, Groq, OpenRouter, or a local self-hosted Ollama server).
- Your API key is stored securely in encrypted Android Keystore / `FlutterSecureStorage`.
- When an AI intent or morning briefing is processed, only the user's transcript prompt is sent over HTTPS directly to the user's configured AI endpoint. AURA operates no intermediary servers in this path.

---

## 3. Device Permissions & Purpose

| Permission | Android Name | Justification |
| :--- | :--- | :--- |
| **System Alert Window** | `SYSTEM_ALERT_WINDOW` | Required to display the floating AURA orb overlay across apps for quick voice capture. |
| **Record Audio** | `RECORD_AUDIO` | Required for speech-to-text recognition when speaking commands. |
| **Notifications** | `POST_NOTIFICATIONS` | Required to deliver reminder alarms and daily morning briefings. |
| **Exact Alarms** | `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` | Required for millisecond-precise reminder alarms that bypass battery sleep / Doze mode. |
| **Boot Completed** | `RECEIVE_BOOT_COMPLETED` | Restores scheduled alarms and the floating orb state after a device reboot. |
| **Foreground Service** | `FOREGROUND_SERVICE` | Keeps the floating orb responsive without consuming excessive battery. |

---

## 4. Third-Party Services
AURA does not embed any tracking SDKs, analytics beacons (e.g., Google Firebase Analytics, Facebook SDK), or advertisement networks.

---

## 5. Data Deletion and Portability
- **Full Data Reset:** You can delete all local data, cached preferences, and stored API keys at any time via **Settings → Reset App Data**.
- **Data Export:** You can export your full database backup as a JSON file at any time via **Settings → Backup & Export**.

---

## 6. Contact & Open Source Inquiries
If you have questions about this privacy policy, you may open an issue in the project repository.
