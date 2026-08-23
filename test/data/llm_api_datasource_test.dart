import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/features/capture/data/datasources/llm_api_datasource.dart';

/// Mocks the flutter_secure_storage platform channel so [SecretStore] works
/// in tests. Backed by an in-memory map.
void mockSecureStorage({String? apiKey}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'read':
        return apiKey;
      case 'write':
        return null;
      case 'delete':
        return null;
      default:
        return null;
    }
  });
}

http.Response _okIntent(Map<String, dynamic> intent) => http.Response(
      jsonEncode({
        'choices': [
          {
            'message': {'content': jsonEncode(intent)}
          }
        ]
      }),
      200,
      headers: {'content-type': 'application/json'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LlmApiDataSource.extractIntentWithMeta', () {
    tearDown(() async {
      // Reset channel mocks between tests.
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
              null);
    });

    test('no API key → offline parser with explanatory notice', () async {
      SharedPreferences.setMockInitialValues({});
      mockSecureStorage(apiKey: null);

      final ds = LlmApiDataSource(client: MockClient((_) async {
        fail('HTTP must not be called without an API key');
      }));

      final outcome = await ds.extractIntentWithMeta(transcript: 'buy milk');

      expect(outcome.usedLocalFallback, isTrue);
      expect(outcome.fallbackNotice, contains('No API key'));
      expect(outcome.result.intentType, isNotEmpty);
    });

    test('401 → throws LlmApiException(auth), never silently falls back',
        () async {
      SharedPreferences.setMockInitialValues({});
      mockSecureStorage(apiKey: 'bad-key');

      final ds = LlmApiDataSource(
        client: MockClient((_) async =>
            http.Response('{"error":"invalid"}', 401)),
      );

      await expectLater(
        ds.extractIntentWithMeta(transcript: 'buy milk'),
        throwsA(isA<LlmApiException>()
            .having((e) => e.kind, 'kind', LlmFailureKind.auth)
            .having((e) => e.isConfigError, 'isConfigError', isTrue)),
      );
    });

    test('404 → throws LlmApiException(modelNotFound)', () async {
      SharedPreferences.setMockInitialValues({});
      mockSecureStorage(apiKey: 'k');

      final ds = LlmApiDataSource(
        client: MockClient((_) async => http.Response('not found', 404)),
      );

      await expectLater(
        ds.extractIntentWithMeta(transcript: 'buy milk'),
        throwsA(isA<LlmApiException>().having(
            (e) => e.kind, 'kind', LlmFailureKind.modelNotFound)),
      );
    });

    test('500 → falls back to local parser with a visible notice', () async {
      SharedPreferences.setMockInitialValues({});
      mockSecureStorage(apiKey: 'k');

      var calls = 0;
      final ds = LlmApiDataSource(
        client: MockClient((_) async {
          calls++;
          return http.Response('server exploded', 500);
        }),
      );

      final outcome = await ds.extractIntentWithMeta(transcript: 'buy milk');
      expect(calls, 1);
      expect(outcome.usedLocalFallback, isTrue);
      expect(outcome.fallbackNotice, isNotNull);
    });

    test('success → parsed IntentResult with no fallback notice', () async {
      SharedPreferences.setMockInitialValues({});
      mockSecureStorage(apiKey: 'k');

      String? capturedAuthHeader;
      Uri? capturedUri;
      Map<String, dynamic>? capturedBody;
      final ds = LlmApiDataSource(
        client: MockClient((req) async {
          capturedAuthHeader = req.headers['Authorization'];
          capturedUri = req.url;
          capturedBody = jsonDecode(req.body) as Map<String, dynamic>;
          return _okIntent({
            'intent_type': 'create_task',
            'title': 'Buy milk',
            'confidence': 0.95,
          });
        }),
      );

      final outcome = await ds.extractIntentWithMeta(
        transcript: 'remind me to buy milk',
        userWorkspaces: ['Personal'],
      );

      expect(outcome.usedLocalFallback, isFalse);
      expect(outcome.result.title, 'Buy milk');
      expect(outcome.result.intentType, 'create_task');
      expect(capturedAuthHeader, 'Bearer k');
      expect(capturedUri!.path, endsWith('/chat/completions'));
      expect(capturedBody!['model'], isNotEmpty);
      // Workspace names are passed to the prompt context.
      final messages = capturedBody!['messages'] as List;
      expect(
        (messages.last as Map)['content'],
        contains('Personal'),
      );
    });

    test('user prefs override defaults for base URL and model', () async {
      SharedPreferences.setMockInitialValues({
        'LLM_BASE_URL': 'https://api.groq.com/openai/v1',
        'LLM_MODEL': 'llama-3.3-70b-versatile',
      });
      mockSecureStorage(apiKey: 'k');

      Uri? capturedUri;
      Map<String, dynamic>? capturedBody;
      final ds = LlmApiDataSource(
        client: MockClient((req) async {
          capturedUri = req.url;
          capturedBody = jsonDecode(req.body) as Map<String, dynamic>;
          return _okIntent({'intent_type': 'create_task', 'title': 'x'});
        }),
      );

      await ds.extractIntentWithMeta(transcript: 'task x');

      expect(capturedUri.toString(),
          startsWith('https://api.groq.com/openai/v1/chat/completions'));
      expect(capturedBody!['model'], 'llama-3.3-70b-versatile');
    });
  });
}
