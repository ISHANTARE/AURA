# Feature Specification: Share-to-AURA & Offline Queue

> **Forensic Rebuild Specification**  
> Complete specification for AURA's Android Share Target subsystem, on-device OCR engine, web scraper, and background offline queue processor.

---

## 1. Share-to-AURA Subsystem

AURA registers as a native Android share target (`ACTION_SEND` and `ACTION_SEND_MULTIPLE`) capable of receiving multi-modal content from any application:

```
External App (Browser, Gallery, Files, Twitter)
                      │
                      ▼ Shares content via Android Share Sheet
AuraShareActivity (Translucent Native Target)
  1. Intercepts intent extras (text, URI, stream).
  2. Copies media/document files into `cacheDir/aura_shared/`.
  3. Purges cached media files older than 24 hours.
  4. Serializes payload to `cacheDir/aura_share_payload.json`.
  5. Launches Flutter `/share` route on cached share engine.
                      │
                      ▼
ShareReceiveScreen (/share)
  1. Fetches payload via MethodChannel `aura/share` (`getInitialSharePayload`).
  2. Runs multi-modal extractors:
     - Image? → OcrDataSource (Google ML Kit On-Device OCR)
     - URL? → LinkReaderDataSource (HTTP Title & Meta Scraper)
     - Text? → Pre-fills note/task buffer
  3. Displays Interactive Processing Sheet to user.
```

---

## 2. Multi-Modal Extractors

### 2.1 On-Device OCR (`OcrDataSource`)
- **Package**: `google_mlkit_text_recognition` (Latin Script).
- **Processing**: Reads image file from local path, processes through `TextRecognizer(script: TextRecognitionScript.latin)`.
- **Memory Safety**: Disposes recognizer immediately in `finally` block to prevent native memory leaks.
- **Error Contract**: Returns empty string for images without text; throws `OcrException` on file read/native plugin failures.

### 2.2 Web Page Metadata Scraper (`LinkReaderDataSource`)
- **Processing**: Executes HTTP GET request (5-second timeout) with standard User-Agent.
- **Extraction**: Scrapes HTML `<title>` tag and `<meta name="description" content="...">`.
- **Output**: Populates `shared_contents.page_title` and `shared_contents.ai_summary`.

---

## 3. Offline Voice Queue & Synchronization Engine

Captures recorded while the device is offline are persisted in SQLite and automatically synchronized when connectivity returns.

```
Offline Voice Capture
        │
        ▼
QueueOfflineTranscriptUseCase
  - Inserts row into `offline_queues`:
    {
      id: UUID,
      type: 'transcript',
      content: transcriptText,
      status: 'pending',
      attempts: 0,
      createdAt: nowMs
    }
        │
        ▼
OfflineQueueProcessor (Active Connectivity Monitor)
  - Listens to `ConnectivityMonitor.onConnectivityChanged`
  - Runs immediate probe on app startup
  - When Online: sequentially drains pending items
```

### 3.1 Draining Protocol & Safeguards (`OfflineQueueProcessor`)

1. **Batch Fetch**: Queries `OfflineQueueDao.getPendingItems()`.
2. **Retry Cap Enforcement**: If `attempts >= 5` (`OfflineQueueDao.maxAttempts`), marks row as `status = 'failed'` and skips processing.
3. **Workspace Resolution**: Resolves default fallback workspace from `workspaceDao.getAll()`. If none exists yet, increments attempt counter and defers.
4. **Intent Extraction**: Calls `LlmApiDataSource.extractIntent(transcript: item.content)`.
5. **Human-in-the-Loop Safeguard (ADR-004)**:
   - **Destructive Intents (`delete_task`, `delete_workspace`)**: NEVER execute silently in the background!
   - Shows instant notification:
     - ID: `NotificationIds.offlineReview` (`10005`).
     - Title: `"Pending Offline Action Review"`
     - Body: `"Voice request \"<transcript>\" requires your confirmation to execute."`
     - Payload: `"route:/search"`
   - Marks item as processed without executing destructive deletion.
6. **Creation Intents (`create_task`, `create_alarm`, `create_workspace`, `add_note`)**:
   - Executes via `ExecuteAiActionUseCase.execute(intent, workspaceId, originalTranscript)`.
   - Posts confirmation notification:
     - ID: `NotificationIds.offlineReview` (`10005`).
     - Title: `"Offline Voice Capture Processed"`
     - Body: `"<resultMessage>. Tap to review."`
     - Payload: `"route:/"`
   - Marks row as `status = 'processed'`, sets `processed_at = nowMs`.
7. **Failure Handling**: On error, logs stack trace and increments `attempts`.
