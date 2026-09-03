import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:passexam/services/secure_vault_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('跨平台硬體級安全金鑰保險庫 (SecureVaultService) 測試', () {
    late SecureVaultService vault;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      vault = SecureVaultService();
    });

    test('能夠安全寫入與讀取機密金鑰 (如 Gemini BYOK API Key)', () async {
      const testApiKey = 'AIzaSyFakeSecretKeyForTest1234567890';
      await vault.writeSecret('gemini_api_key', testApiKey);

      final exists = await vault.containsKey('gemini_api_key');
      expect(exists, true);

      final retrieved = await vault.readSecret('gemini_api_key');
      expect(retrieved, testApiKey);
    });

    test('能夠正確刪除機密金鑰，且再次讀取回傳 null', () async {
      await vault.writeSecret('temp_token', 'token_abcdef');
      expect(await vault.readSecret('temp_token'), 'token_abcdef');

      await vault.deleteSecret('temp_token');
      expect(await vault.readSecret('temp_token'), null);
      expect(await vault.containsKey('temp_token'), false);
    });

    test('能夠一鍵清除全數機密保存庫項目 (clearAll)', () async {
      await vault.writeSecret('key_1', 'val_1');
      await vault.writeSecret('key_2', 'val_2');

      await vault.clearAll();
      expect(await vault.readSecret('key_1'), null);
      expect(await vault.readSecret('key_2'), null);
    });
  });
}
