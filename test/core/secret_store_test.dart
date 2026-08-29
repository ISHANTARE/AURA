import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/core/security/secret_store.dart';

class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  late _FakeSecureStorage fakeStorage;
  late SecretStore secretStore;

  setUp(() {
    fakeStorage = _FakeSecureStorage();
    secretStore = SecretStore(storage: fakeStorage);
    SharedPreferences.setMockInitialValues({});
  });

  group('SecretStore Unit Tests', () {
    test('getApiKey returns null when no key is stored', () async {
      final key = await secretStore.getApiKey();
      expect(key, isNull);
    });

    test('setApiKey stores key securely and getApiKey retrieves it', () async {
      await secretStore.setApiKey('test-gemini-key-12345');
      final retrieved = await secretStore.getApiKey();
      expect(retrieved, 'test-gemini-key-12345');
    });

    test('deleteApiKey removes stored key', () async {
      await secretStore.setApiKey('key-to-delete');
      await secretStore.deleteApiKey();
      final retrieved = await secretStore.getApiKey();
      expect(retrieved, isNull);
    });

    test('migrateLegacyKey migrates key from SharedPreferences to Keystore and deletes legacy key', () async {
      SharedPreferences.setMockInitialValues({'gemini_api_key': 'legacy-plain-text-key'});

      await secretStore.migrateLegacyKey();

      final secureKey = await secretStore.getApiKey();
      expect(secureKey, 'legacy-plain-text-key');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('gemini_api_key'), isNull);
    });

    test('migrateLegacyKey does not overwrite existing secure key', () async {
      await secretStore.setApiKey('existing-secure-key');
      SharedPreferences.setMockInitialValues({'gemini_api_key': 'legacy-key-ignored'});

      await secretStore.migrateLegacyKey();

      final secureKey = await secretStore.getApiKey();
      expect(secureKey, 'existing-secure-key');
    });
  });
}
