enum UserRole {
  admin,
  viewer,
  pending,
  internalTester,
  publicTester,
  guest,
}

extension UserRoleExtension on UserRole {
  String get nameString {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.viewer:
        return 'viewer';
      case UserRole.pending:
        return 'pending';
      case UserRole.internalTester:
        return 'internalTester';
      case UserRole.publicTester:
        return 'publicTester';
      case UserRole.guest:
        return 'guest';
    }
  }

  static UserRole fromString(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'viewer':
        return UserRole.viewer;
      case 'pending':
        return UserRole.pending;
      case 'internaltester':
        return UserRole.internalTester;
      case 'publictester':
        return UserRole.publicTester;
      case 'guest':
      default:
        return UserRole.guest;
    }
  }
}

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String activeDeviceId;
  final DateTime createdAt;
  final DateTime? subscriptionExpiry;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.activeDeviceId,
    required this.createdAt,
    this.subscriptionExpiry,
  });

  bool get isPro {
    if (role == UserRole.admin || role == UserRole.internalTester) return true;
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.nameString,
      'activeDeviceId': activeDeviceId,
      'createdAt': createdAt.toIso8601String(),
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? map['name'] ?? 'User',
      role: UserRoleExtension.fromString(map['role']),
      activeDeviceId: map['activeDeviceId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      subscriptionExpiry: map['subscriptionExpiry'] != null
          ? DateTime.tryParse(map['subscriptionExpiry'].toString())
          : null,
    );
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    String? activeDeviceId,
    DateTime? createdAt,
    DateTime? subscriptionExpiry,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      activeDeviceId: activeDeviceId ?? this.activeDeviceId,
      createdAt: createdAt ?? this.createdAt,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }
}
