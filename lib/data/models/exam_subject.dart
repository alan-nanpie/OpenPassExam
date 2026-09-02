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
  });

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
    );
  }
}
