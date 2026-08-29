import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/extracted_intent.dart';
import 'rate_limiter.dart';

/// Enum representing categories of LLM API failures.
enum LlmFailureKind {
  auth,
  modelNotFound,
  rateLimited,
  network,
  badResponse,
  noApiKey,
}

/// Typed exception representing an LLM API error.
class LlmApiException implements Exception {
  final LlmFailureKind kind;
  final String message;
  final int? statusCode;

  const LlmApiException({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'LlmApiException($kind, statusCode: $statusCode): $message';
}

/// Known provider presets for BYOK LLM configurations.
class LlmProviderPreset {
  final String name;
  final String baseUrl;
  final String defaultModel;

  const LlmProviderPreset({
    required this.name,
    required this.baseUrl,
    required this.defaultModel,
  });

  static const gemini = LlmProviderPreset(
    name: 'Google Gemini',
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai/',
    defaultModel: 'gemini-2.0-flash',
  );

  static const nvidia = LlmProviderPreset(
    name: 'NVIDIA NIM',
    baseUrl: 'https://integrate.api.nvidia.com/v1',
    defaultModel: 'meta/llama-3.3-70b-instruct',
  );

  static const groq = LlmProviderPreset(
    name: 'Groq Cloud',
    baseUrl: 'https://api.groq.com/openai/v1',
    defaultModel: 'llama-3.3-70b-versatile',
  );

  static const openRouter = LlmProviderPreset(
    name: 'OpenRouter',
    baseUrl: 'https://openrouter.ai/api/v1',
    defaultModel: 'google/gemini-2.0-flash-001',
  );

  static const localOllama = LlmProviderPreset(
    name: 'Local LLM (Ollama)',
    baseUrl: 'http://10.0.2.2:11434/v1',
    defaultModel: 'llama3.2',
  );

  static const all = [
    gemini,
    nvidia,
    groq,
    openRouter,
    localOllama,
  ];
}

/// Client datasource communicating with OpenAI-compatible LLM endpoints to extract intent.
class LlmApiDataSource {
  final http.Client _client;
  final RateLimiter _rateLimiter;

  LlmApiDataSource({
    http.Client? client,
    RateLimiter? rateLimiter,
  })  : _client = client ?? http.Client(),
        _rateLimiter = rateLimiter ?? RateLimiter();

  static const String systemPrompt = '''
You are AURA's intent extraction & command intelligence engine for an AI life management app.
Your job is to parse a voice transcript, identify the core action/intent, and extract structured metadata.

ACTIONS & INTENTS:
- "create_task": Task (something to do, title, deadline, priority, workspace, notes).
- "create_reminder": Timed reminder/deadline to alert before submission.
- "create_event": Event (meetings, interview, placement talk, with start time, end time, location).
- "create_alarm": General time-of-day alarm (e.g. "add an alarm for 1.45pm today", "set alarm for 7am").
- "create_workspace": Requests to create a workspace/folder (e.g. "Create a workspace for Placement Prep").
- "delete_task": Requests to remove or cancel a task.
- "delete_workspace": Requests to remove a workspace.
- "add_note": Pure freeform thoughts or ideas without a task/alarm.

CRITICAL RULES:
1. Return ONLY valid JSON — no markdown backticks, no text explanations.
2. NOTES CATCH-ALL RULE: Put any extra details, subtasks, instructions, or descriptions inside "notes".
3. ALARM RULE: If the user says "add an alarm", "set alarm", or mentions a specific wake-up/alert time without task context, set intent_type to "create_alarm".
4. Relative dates: Resolve relative to current_datetime in context.

EXAMPLES:
- "Add an alarm for 1.45pm today"
  → {"intent_type": "create_alarm", "title": "Alarm 1:45 PM", "deadline_iso": "2026-07-27T13:45:00"}

- "Create a new workspace named IIT Prep with blue color"
  → {"intent_type": "create_workspace", "title": "IIT Prep", "workspace_color_hex": "#3B82F6"}

- "Remind me tomorrow at 5pm to call doctor and ask about prescription"
  → {"intent_type": "create_reminder", "title": "Call doctor", "deadline_iso": "<tomorrow 17:00>", "notes": "ask about prescription"}

- "Just note down project submission portal opens on Friday"
  → {"intent_type": "add_note", "title": "Project submission portal opens on Friday", "notes": "project submission portal opens on Friday"}

OUTPUT SCHEMA:
{
  "intent_type": "create_task" | "create_reminder" | "create_event" | "create_alarm" | "create_workspace" | "delete_task" | "delete_workspace" | "add_note",
  "title": string | null,
  "target_name": string | null,
  "deadline_iso": string | null,
  "event_start_iso": string | null,
  "event_end_iso": string | null,
  "event_location": string | null,
  "workspace_hint": string | null,
  "workspace_color_hex": string | null,
  "workspace_icon_key": string | null,
  "priority": "high" | "medium" | "low" | null,
  "is_recurring": boolean,
  "recurrence_type": "daily" | "weekly" | "custom" | null,
  "reminders": [
    {
      "offset_value": integer,
      "offset_unit": "minutes" | "hours" | "days",
      "type": "notification" | "alarm"
    }
  ],
  "notes": string | null,
  "confidence": float
}
''';

  /// Calls the configured LLM API to extract structured intent from [transcript].
  Future<ExtractedIntent> extractIntent({
    required String transcript,
    required String apiKey,
    required String baseUrl,
    required String model,
    List<String> existingWorkspaces = const [],
    DateTime? now,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const LlmApiException(
        kind: LlmFailureKind.noApiKey,
        message: 'No API key configured. Please set your API key in Settings.',
      );
    }

    // Rate limiting
    await _rateLimiter.acquire();

    final currentDt = now ?? DateTime.now();
    final userPrompt = '''
Context:
- Current datetime: ${currentDt.toIso8601String()}
- User's existing workspaces: ${existingWorkspaces.isEmpty ? 'None' : existingWorkspaces.join(', ')}

Voice transcript:
"$transcript"

Extract the intent and return JSON only. Ensure deadline_iso is correctly resolved relative to Current datetime.
''';

    // Normalize endpoint URL
    var endpoint = baseUrl.trim();
    if (!endpoint.endsWith('/')) endpoint += '/';
    if (!endpoint.endsWith('chat/completions')) {
      endpoint += 'chat/completions';
    }

    final requestBody = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': 0.1,
      'response_format': {'type': 'json_object'},
    });

    try {
      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${apiKey.trim()}',
            },
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = decoded['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          throw const LlmApiException(
            kind: LlmFailureKind.badResponse,
            message: 'LLM returned an empty choice array.',
          );
        }

        final messageObj = choices[0]['message'] as Map<String, dynamic>?;
        final content = messageObj?['content'] as String?;
        if (content == null || content.isEmpty) {
          throw const LlmApiException(
            kind: LlmFailureKind.badResponse,
            message: 'LLM returned empty message content.',
          );
        }

        final cleanJson = cleanJsonString(content);
        final parsedMap = jsonDecode(cleanJson) as Map<String, dynamic>;
        return ExtractedIntent.fromJson(parsedMap);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw LlmApiException(
          kind: LlmFailureKind.auth,
          statusCode: response.statusCode,
          message: 'Invalid API key or unauthorized. Please check your credentials in Settings.',
        );
      } else if (response.statusCode == 404) {
        throw LlmApiException(
          kind: LlmFailureKind.modelNotFound,
          statusCode: response.statusCode,
          message: 'Selected model "$model" not found on this provider.',
        );
      } else if (response.statusCode == 429) {
        throw LlmApiException(
          kind: LlmFailureKind.rateLimited,
          statusCode: response.statusCode,
          message: 'Provider rate limit or quota exceeded.',
        );
      } else {
        throw LlmApiException(
          kind: LlmFailureKind.badResponse,
          statusCode: response.statusCode,
          message: 'LLM API request failed with status code ${response.statusCode}: ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw LlmApiException(
        kind: LlmFailureKind.network,
        message: 'Network connection failed: ${e.message}',
      );
    } on TimeoutException {
      throw const LlmApiException(
        kind: LlmFailureKind.network,
        message: 'LLM API request timed out after 30 seconds.',
      );
    } on FormatException catch (e) {
      throw LlmApiException(
        kind: LlmFailureKind.badResponse,
        message: 'Failed to parse JSON response: ${e.message}',
      );
    }
  }

  /// Extracts clean JSON string by stripping markdown fences or slicing between `{` and `}`.
  static String cleanJsonString(String raw) {
    var text = raw.trim();

    // Strategy 1: Find outermost { and }
    final firstBrace = text.indexOf('{');
    final lastBrace = text.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      return text.substring(firstBrace, lastBrace + 1).trim();
    }

    // Strategy 2: Strip markdown code fences
    if (text.startsWith('```json')) {
      text = text.substring(7);
    } else if (text.startsWith('```')) {
      text = text.substring(3);
    }
    if (text.endsWith('```')) {
      text = text.substring(0, text.length - 3);
    }

    return text.trim();
  }
}
