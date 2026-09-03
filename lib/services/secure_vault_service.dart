import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 跨平台硬體級安全機密保存庫介面 (Cross-Platform Hardware-Backed Secure Vault)
abstract class ISecureVaultService {
  Future<void> writeSecret(String key, String value);
  Future<String?> readSecret(String key);
  Future<void> deleteSecret(String key);
  Future<bool> containsKey(String key);
  Future<void> clearAll();
}

/// 跨平台硬體安全保險庫實作
///
/// 針對各大作業系統自動對接原生最高規格硬體級加密：
/// - **Android**: Android Keystore Provider + EncryptedSharedPreferences (TEE / StrongBox 硬體安全晶片)
/// - **Windows**: Windows Data Protection API (DPAPI / CryptProtectData，綁定 Windows 登入身分與 TPM 晶片)
/// - **Linux**: Linux Secret Service API (GNOME Keyring / KWallet 系統守護進程)
/// - **macOS / iOS**: Apple Keychain Services + Secure Enclave 隔離硬體處理器
/// - **Web**: Web Crypto API 安全沙箱隔離
class SecureVaultService implements ISecureVaultService {
  final FlutterSecureStorage _storage;

  SecureVaultService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                resetOnError: true,
              ),
              wOptions: WindowsOptions(
                useBackwardCompatibility: false,
              ),
              mOptions: MacOsOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
              lOptions: LinuxOptions(),
            );

  @override
  Future<void> writeSecret(String key, String value) async {
    await _storage.write(key: key, value: value.trim());
  }

  @override
  Future<String?> readSecret(String key) async {
    try {
      final val = await _storage.read(key: key);
      if (val == null || val.trim().isEmpty) return null;
      return val.trim();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteSecret(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
