import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:aura/features/capture/data/llm_api_datasource.dart';

void main() {
  group('LlmApiDataSource Unit Tests', () {
    test('throws noApiKey error when API key is empty', () async {
      final dataSource = LlmApiDataSource();
      expect(
        () => dataSource.extractIntent(
          transcript: 'set an alarm for 7am',
          apiKey: '   ',
          baseUrl: 'https://example.com/v1',
          model: 'test-model',
        ),
        throwsA(
          isA<LlmApiException>().having(
            (e) => e.kind,
            'kind',
            LlmFailureKind.noApiKey,
          ),
        ),
      );
    });

    test('extracts clean intent from valid 200 JSON response', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer test-api-key');
        expect(request.url.path.endsWith('chat/completions'), true);

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': jsonEncode({
                    'intent_type': 'create_alarm',
                    'title': 'Alarm 7:00 AM',
                    'deadline_iso': '2026-08-30T07:00:00',
                    'confidence': 0.95,
                  }),
                },
              }
            ],
          }),
          200,
        );
      });

      final dataSource = LlmApiDataSource(client: mockClient);
      final intent = await dataSource.extractIntent(
        transcript: 'Set alarm for 7 AM tomorrow',
        apiKey: 'test-api-key',
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai/',
        model: 'gemini-2.0-flash',
      );

      expect(intent.intentType, 'create_alarm');
      expect(intent.title, 'Alarm 7:00 AM');
      expect(intent.confidence, 0.95);
    });

    test('extracts intent when response is wrapped in markdown code fences', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': '```json\n{\n  "intent_type": "create_task",\n  "title": "Study Mathematics",\n  "priority": "high"\n}\n```',
                },
              }
            ],
          }),
          200,
        );
      });

      final dataSource = LlmApiDataSource(client: mockClient);
      final intent = await dataSource.extractIntent(
        transcript: 'urgent task study mathematics',
        apiKey: 'test-api-key',
        baseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai/',
        model: 'gemini-2.0-flash',
      );

      expect(intent.intentType, 'create_task');
      expect(intent.title, 'Study Mathematics');
      expect(intent.priority, 'high');
    });

    test('throws LlmApiException with auth error on 401 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Invalid API Key"}', 401);
      });

      final dataSource = LlmApiDataSource(client: mockClient);
      expect(
        () => dataSource.extractIntent(
          transcript: 'test',
          apiKey: 'invalid-key',
          baseUrl: 'https://api.groq.com/openai/v1',
          model: 'llama-3.3-70b-versatile',
        ),
        throwsA(
          isA<LlmApiException>().having(
            (e) => e.kind,
            'kind',
            LlmFailureKind.auth,
          ),
        ),
      );
    });

    test('throws LlmApiException with rateLimited error on 429 response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": "Rate limit reached"}', 429);
      });

      final dataSource = LlmApiDataSource(client: mockClient);
      expect(
        () => dataSource.extractIntent(
          transcript: 'test',
          apiKey: 'valid-key',
          baseUrl: 'https://api.groq.com/openai/v1',
          model: 'llama-3.3-70b-versatile',
        ),
        throwsA(
          isA<LlmApiException>().having(
            (e) => e.kind,
            'kind',
            LlmFailureKind.rateLimited,
          ),
        ),
      );
    });

    test('cleanJsonString correctly extracts JSON from surrounding conversational text', () {
      const raw = 'Sure! Here is the JSON you requested:\n\n{"intent_type": "create_task", "title": "Buy milk"}\n\nLet me know if you need anything else!';
      final cleaned = LlmApiDataSource.cleanJsonString(raw);
      expect(cleaned, '{"intent_type": "create_task", "title": "Buy milk"}');
    });
  });
}
