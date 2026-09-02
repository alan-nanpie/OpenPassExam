enum StudioToolType {
  studyGuide,
  faq,
  briefing,
  timeline,
  cheatSheet,
  custom,
}

extension StudioToolTypeExtension on StudioToolType {
  String get title {
    switch (this) {
      case StudioToolType.studyGuide:
        return '研讀指南 (Study Guide)';
      case StudioToolType.faq:
        return '常見考點問答 (FAQ)';
      case StudioToolType.briefing:
        return '架構精華簡介 (Briefing)';
      case StudioToolType.timeline:
        return '技術與協定演進 (Timeline)';
      case StudioToolType.cheatSheet:
        return 'Cisco CLI 速查表 (Cheat Sheet)';
      case StudioToolType.custom:
        return '自訂聚焦產出 (Custom Artifact)';
    }
  }

  String get iconName {
    switch (this) {
      case StudioToolType.studyGuide:
        return 'menu_book';
      case StudioToolType.faq:
        return 'help_outline';
      case StudioToolType.briefing:
        return 'summarize';
      case StudioToolType.timeline:
        return 'timeline';
      case StudioToolType.cheatSheet:
        return 'code';
      case StudioToolType.custom:
        return 'auto_awesome';
    }
  }
}

class StudyArtifact {
  final String id;
  final String title;
  final StudioToolType toolType;
  final String contentMarkdown;
  final String customFocusPrompt;
  final DateTime createdAt;
  final String examId;

  StudyArtifact({
    required this.id,
    required this.title,
    required this.toolType,
    required this.contentMarkdown,
    this.customFocusPrompt = '',
    required this.createdAt,
    required this.examId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'toolType': toolType.name,
      'contentMarkdown': contentMarkdown,
      'customFocusPrompt': customFocusPrompt,
      'createdAt': createdAt.toIso8601String(),
      'examId': examId,
    };
  }

  factory StudyArtifact.fromMap(Map<String, dynamic> map) {
    return StudyArtifact(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      toolType: StudioToolType.values.firstWhere(
        (t) => t.name == map['toolType'],
        orElse: () => StudioToolType.studyGuide,
      ),
      contentMarkdown: map['contentMarkdown'] ?? '',
      customFocusPrompt: map['customFocusPrompt'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      examId: map['examId'] ?? '',
    );
  }
}
