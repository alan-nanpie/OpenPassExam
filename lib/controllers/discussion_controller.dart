import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/question_comment.dart';
import '../data/repositories/discussion_repository.dart';

class DiscussionController extends ChangeNotifier {
  final IDiscussionRepository repository;

  final Map<String, List<QuestionComment>> _commentsByQuestion = {};
  bool _isLoading = false;
  String? _errorMessage;

  DiscussionController({required this.repository});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<QuestionComment> getCommentsForQuestion(String questionId) {
    return _commentsByQuestion[questionId] ?? [];
  }

  Future<void> loadComments(String questionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final comments = await repository.getComments(questionId);
      _commentsByQuestion[questionId] = comments;
    } catch (e) {
      _errorMessage = '載入討論區留言失敗：$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String questionId,
    required String examId,
    required String authorId,
    required String authorName,
    required String authorRole,
    required String content,
  }) async {
    if (content.trim().isEmpty) return false;

    final newComment = QuestionComment(
      id: 'comment_${const Uuid().v4().substring(0, 8)}',
      questionId: questionId,
      examId: examId,
      authorId: authorId,
      authorName: authorName,
      authorRole: authorRole,
      content: content.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await repository.addComment(newComment);
      final list = _commentsByQuestion[questionId] ?? [];
      list.add(newComment);
      _commentsByQuestion[questionId] = list;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '發表留言失敗：$e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateComment({
    required QuestionComment comment,
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    try {
      await repository.updateComment(
        comment,
        currentUserId: currentUserId,
        isAdmin: isAdmin,
      );
      final list = _commentsByQuestion[comment.questionId] ?? [];
      final idx = list.indexWhere((c) => c.id == comment.id);
      if (idx >= 0) {
        list[idx] = comment;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComment({
    required String commentId,
    required String questionId,
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    try {
      await repository.deleteComment(
        commentId,
        questionId,
        currentUserId: currentUserId,
        isAdmin: isAdmin,
      );
      final list = _commentsByQuestion[questionId] ?? [];
      list.removeWhere((c) => c.id == commentId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
