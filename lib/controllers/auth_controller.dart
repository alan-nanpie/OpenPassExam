import 'package:flutter/foundation.dart';
import '../data/models/app_user.dart';
import '../data/repositories/user_repository.dart';

class AuthController extends ChangeNotifier {
  final IUserRepository userRepository;
  AppUser? _currentUser;
  bool _isLoading = false;

  AuthController({required this.userRepository});

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await userRepository.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginAsGuest() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await userRepository.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    final deviceId = await userRepository.getOrGenerateDeviceId();
    final user = AppUser(
      uid: 'usr_google_6688',
      email: 'alex.engineer@gmail.com',
      displayName: 'Alex Chen (Cisco Pro)',
      role: UserRole.admin,
      activeDeviceId: deviceId,
      createdAt: DateTime.now(),
      subscriptionExpiry: DateTime.now().add(const Duration(days: 365)),
    );
    await userRepository.saveUser(user);
    _currentUser = user;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> switchRole(UserRole role) async {
    if (_currentUser == null) return;
    await userRepository.switchRole(role);
    _currentUser = _currentUser!.copyWith(role: role);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }
}
