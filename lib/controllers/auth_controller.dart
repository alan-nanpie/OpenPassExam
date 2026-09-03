import 'package:flutter/foundation.dart';
import '../data/models/app_user.dart';
import '../data/repositories/user_repository.dart';

class AuthController extends ChangeNotifier {
  final IUserRepository userRepository;
  AppUser? _currentUser;
  bool _isLoading = false;

  bool _hasDeviceConflict = false;

  AuthController({required this.userRepository});

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get hasDeviceConflict => _hasDeviceConflict;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await userRepository.getCurrentUser();
    await checkDeviceBinding();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkDeviceBinding() async {
    if (_currentUser == null) {
      _hasDeviceConflict = false;
      return false;
    }
    final currentLocalDeviceId = await userRepository.getOrGenerateDeviceId();
    final conflict = _currentUser!.activeDeviceId.isNotEmpty &&
        _currentUser!.activeDeviceId != currentLocalDeviceId;
    _hasDeviceConflict = conflict;
    notifyListeners();
    return conflict;
  }

  Future<void> rebindDevice() async {
    if (_currentUser == null) return;
    final currentLocalDeviceId = await userRepository.getOrGenerateDeviceId();
    final updated = _currentUser!.copyWith(activeDeviceId: currentLocalDeviceId);
    await userRepository.saveUser(updated);
    _currentUser = updated;
    _hasDeviceConflict = false;
    notifyListeners();
  }

  Future<void> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await userRepository.getCurrentUser();
    await checkDeviceBinding();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle({
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final selectedEmail = (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : 'google.learner@gmail.com';
      final selectedName = (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : selectedEmail.split('@').first;

      final user = await userRepository.signInWithGoogleAccount(
        email: selectedEmail,
        displayName: selectedName,
        photoUrl: photoUrl,
        role: role,
      );
      _currentUser = user;
      _hasDeviceConflict = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchRole(UserRole role) async {
    if (_currentUser == null) return;
    await userRepository.switchRole(role);
    _currentUser = _currentUser!.copyWith(role: role);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await userRepository.clearUser();
    _currentUser = await userRepository.getCurrentUser();
    _hasDeviceConflict = false;
    _isLoading = false;
    notifyListeners();
  }
}
