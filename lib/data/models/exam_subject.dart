class ExamSubject {
  final String id;
  final String code;
  final String title;
  final String category;
  final String description;
  final int totalQuestions;
  final List<String> domains;
  final String iconName;
  final bool isPopular;
  final String? creatorId; // 若為 null 則為官方科目；若有值則為使用者自創自訂科目
  final String? creatorName;

  ExamSubject({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.description,
    required this.totalQuestions,
    required this.domains,
    required this.iconName,
    this.isPopular = false,
    this.creatorId,
    this.creatorName,
  });

  /// 檢查是否為官方科目
  bool get isOfficial => creatorId == null || creatorId == 'official' || creatorId == 'system';

  /// 檢查當前使用者是否為自訂科目的建立者本人
  bool isOwner(String? currentUid) {
    if (currentUid == null || currentUid.isEmpty) return false;
    return creatorId != null && creatorId == currentUid;
  }

  /// 判斷是否有編輯或刪除此科目的權限 (建立者本人或管理員)
  bool canEdit({String? currentUid, bool isAdmin = false}) {
    if (isAdmin) return true;
    return isOwner(currentUid);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'category': category,
      'description': description,
      'totalQuestions': totalQuestions,
      'domains': domains,
      'iconName': iconName,
      'isPopular': isPopular,
      'creatorId': creatorId,
      'creatorName': creatorName,
    };
  }

  factory ExamSubject.fromMap(Map<String, dynamic> map) {
    return ExamSubject(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      domains: List<String>.from(map['domains'] ?? []),
      iconName: map['iconName'] ?? 'router',
      isPopular: map['isPopular'] ?? false,
      creatorId: map['creatorId'] ?? map['creator_id'],
      creatorName: map['creatorName'] ?? map['creator_name'],
    );
  }
}
