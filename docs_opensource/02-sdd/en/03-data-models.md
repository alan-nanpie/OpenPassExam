# 03. Data Models

## 1. Question Model (`Question`)
Supports Firestore documents with dual `camelCase` and `snake_case` serialization:

```dart
class Question {
  final String id;
  final String examId;
  final String type;
  final String title;
  final List<String> options;
  final List<int> correctAnswer;
  final String explanation;
  final String? explanationJa;
  final String? explanationZhTw;
  final String topic;
  final String? imageUrl;
  final bool isApproved;

  Question({
    required this.id,
    required this.examId,
    required this.type,
    required this.title,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.explanationJa,
    this.explanationZhTw,
    required this.topic,
    this.imageUrl,
    required this.isApproved,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? map['question_id'] ?? '',
      examId: map['examId'] ?? map['exam_id'] ?? '',
      type: map['type'] ?? 'SINGLE_CHOICE',
      title: map['title'] ?? map['question_text'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: List<int>.from(map['correctAnswer'] ?? map['correct_answer'] ?? []),
      explanation: map['explanation'] ?? '',
      explanationJa: map['explanationJa'] ?? map['explanation_ja'],
      explanationZhTw: map['explanationZhTw'] ?? map['explanation_zh_tw'],
      topic: map['topic'] ?? '',
      imageUrl: map['imageUrl'] ?? map['image_url'],
      isApproved: map['isApproved'] ?? map['is_approved'] ?? true,
    );
  }
}
```
