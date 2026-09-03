import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/app_user.dart';

abstract class IUserRepository {
  Future<AppUser> getCurrentUser();
  Future<void> saveUser(AppUser user);
  Future<void> switchRole(UserRole newRole);
  Future<void> updateSubscription(DateTime expiryDate);
  Future<String> getOrGenerateDeviceId();
  Future<AppUser> signInWithGoogleAccount({
    required String email,
    required String displayName,
    String? photoUrl,
    UserRole? role,
  });
  Future<void> clearUser();
}

class UserRepository implements IUserRepository {
  final SharedPreferences _prefs;
  AppUser? _cachedUser;

  UserRepository(this._prefs);

  @override
  Future<String> getOrGenerateDeviceId() async {
    String? deviceId = _prefs.getString(AppConstants.prefKeyActiveDeviceId);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = 'dev_${const Uuid().v4().substring(0, 8)}';
      await _prefs.setString(AppConstants.prefKeyActiveDeviceId, deviceId);
    }
    return deviceId;
  }

  @override
  Future<AppUser> getCurrentUser() async {
    if (_cachedUser != null) return _cachedUser!;

    final deviceId = await getOrGenerateDeviceId();
    final rawUser = _prefs.getString(AppConstants.prefKeyUserData);

    if (rawUser != null) {
      try {
        final decoded = jsonDecode(rawUser);
        _cachedUser = AppUser.fromMap(Map<String, dynamic>.from(decoded));
        return _cachedUser!;
      } catch (_) {}
    }

    // 預設訪客使用者
    final defaultUser = AppUser(
      uid: 'usr_guest_8888',
      email: 'guest@passexam.app',
      displayName: '訪客學員 (未登入)',
      role: UserRole.guest,
      activeDeviceId: deviceId,
      createdAt: DateTime.now(),
      subscriptionExpiry: null,
      authProvider: 'guest',
    );

    await saveUser(defaultUser);
    return defaultUser;
  }

  @override
  Future<AppUser> signInWithGoogleAccount({
    required String email,
    required String displayName,
    String? photoUrl,
    UserRole? role,
  }) async {
    final deviceId = await getOrGenerateDeviceId();
    // 依據 Google 帳號產生唯一的 UID
    final cleanEmail = email.trim().toLowerCase();
    final sanitizedPrefix = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final googleUid = 'google_$sanitizedPrefix';

    // 判斷角色：若原先指定 admin，或預設賦予具有 UGC 出題權限的 creator
    final effectiveRole = role ??
        (cleanEmail.contains('admin') ? UserRole.admin : UserRole.creator);

    final googleUser = AppUser(
      uid: googleUid,
      email: cleanEmail,
      displayName: displayName.trim().isNotEmpty ? displayName.trim() : cleanEmail.split('@').first,
      role: effectiveRole,
      activeDeviceId: deviceId,
      createdAt: DateTime.now(),
      subscriptionExpiry: DateTime.now().add(const Duration(days: 365)),
      photoUrl: photoUrl,
      authProvider: 'google',
    );

    await saveUser(googleUser);
    return googleUser;
  }

  @override
  Future<void> clearUser() async {
    _cachedUser = null;
    await _prefs.remove(AppConstants.prefKeyUserData);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    _cachedUser = user;
    await _prefs.setString(AppConstants.prefKeyUserData, jsonEncode(user.toMap()));
  }

  @override
  Future<void> switchRole(UserRole newRole) async {
    final current = await getCurrentUser();
    final updated = current.copyWith(role: newRole);
    await saveUser(updated);
  }

  @override
  Future<void> updateSubscription(DateTime expiryDate) async {
    final current = await getCurrentUser();
    final updated = current.copyWith(
      subscriptionExpiry: expiryDate,
      role: UserRole.viewer, // 升級為付費用戶角色
    );
    await saveUser(updated);
  }
}
