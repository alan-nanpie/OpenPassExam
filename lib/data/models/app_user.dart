enum UserRole {
  admin,
  creator,
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
      case UserRole.creator:
        return 'creator';
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

  String get labelZhTw {
    switch (this) {
      case UserRole.admin:
        return '👑 系統管理員';
      case UserRole.creator:
        return '✍️ 出題創作者 (UGC)';
      case UserRole.viewer:
        return '🎓 備考學員';
      case UserRole.pending:
        return '⏳ 待審核會員';
      case UserRole.internalTester:
        return '🧪 內部測試員';
      case UserRole.publicTester:
        return '🚀 公開測試員';
      case UserRole.guest:
        return '👤 訪客體驗';
    }
  }

  static UserRole fromString(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'creator':
        return UserRole.creator;
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
  final String? photoUrl;
  final String authProvider; // 'google' | 'guest' | 'password'

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.activeDeviceId,
    required this.createdAt,
    this.subscriptionExpiry,
    this.photoUrl,
    this.authProvider = 'google',
  });

  /// 是否為訪客 (未登入)
  bool get isGuest => role == UserRole.guest || uid.startsWith('usr_guest');

  /// 是否為已登入使用者
  bool get isLoggedIn => !isGuest;

  /// 是否為 Google 登入帳號
  bool get isGoogleUser => authProvider == 'google';

  /// 是否為 Pro 訂閱會員
  bool get isPro {
    if (role == UserRole.admin || role == UserRole.internalTester || role == UserRole.creator) {
      return true;
    }
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  /// 是否為系統管理員
  bool get isAdmin => role == UserRole.admin;

  // === 角色權限控管 (RBAC Matrix) ===

  /// 是否具備「自訂建立新考試科目」的權限 (管理員、出題創作者、Pro會員與所有登入者預設皆可發揮UGC社群力量)
  bool get canCreateSubject => isLoggedIn && (isAdmin || role == UserRole.creator || role == UserRole.viewer || isPro);

  /// 是否具備「在科目下建立新考題」的權限
  bool get canCreateQuestion => isLoggedIn;

  /// 是否可不受限存取 AI 導師
  bool get canAccessAiTutor => isLoggedIn || isPro;

  /// 是否可存取完整模擬考
  bool get canAccessMockExam => isLoggedIn;

  /// 是否可在討論區留言發言
  bool get canComment => isLoggedIn;

  /// 是否可管理全站系統模型設定與審核考題
  bool get canManageSystem => isAdmin;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.nameString,
      'activeDeviceId': activeDeviceId,
      'createdAt': createdAt.toIso8601String(),
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'photoUrl': photoUrl,
      'authProvider': authProvider,
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
      photoUrl: map['photoUrl'] ?? map['photo_url'],
      authProvider: map['authProvider'] ?? map['auth_provider'] ?? 'google',
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
    String? photoUrl,
    String? authProvider,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      activeDeviceId: activeDeviceId ?? this.activeDeviceId,
      createdAt: createdAt ?? this.createdAt,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
    );
  }
}
