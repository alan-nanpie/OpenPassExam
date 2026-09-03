import '../datasources/local_persistent_cache.dart';
import '../models/question_comment.dart';

abstract class IDiscussionRepository {
  Future<List<QuestionComment>> getComments(String questionId);
  Future<void> addComment(QuestionComment comment);
  Future<void> updateComment(
    QuestionComment comment, {
    required String currentUserId,
    bool isAdmin = false,
  });
  Future<void> deleteComment(
    String commentId,
    String questionId, {
    required String currentUserId,
    bool isAdmin = false,
  });
}

class DiscussionRepository implements IDiscussionRepository {
  final LocalPersistentCache localCache;

  DiscussionRepository({required this.localCache});

  @override
  Future<List<QuestionComment>> getComments(String questionId) async {
    // 1. 讀取本機快取
    final cached = localCache.getCachedComments(questionId);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // 2. 初始社群種子討論內容 (讓每題均有熱烈討論供示範多使用者讀取與交流)
    final initialComments = [
      QuestionComment(
        id: 'comment_seed_${questionId}_01',
        questionId: questionId,
        examId: 'cisco-200-301',
        authorId: 'user_alan_ccie',
        authorName: 'Alan (CCIE #68921)',
        authorRole: 'internalTester',
        content: '這題是 Cisco 考試的高頻題！核心考點在於辨識轉發面 (Data Plane) 與控制面 (Control Plane) 的職責邊界，切記 CEF (Cisco Express Forwarding) 是透過 FIB 與 Adjacency Table 加速轉發。',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      QuestionComment(
        id: 'comment_seed_${questionId}_02',
        questionId: questionId,
        examId: 'cisco-200-301',
        authorId: 'user_sophia_learner',
        authorName: 'Sophia 考生',
        authorRole: 'viewer',
        content: '感謝詳解！一開始選項 B 跟 C 很容易猶豫，配合 AI 助教的「高鐵收發室」生活化比喻後，立刻就看懂了！',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];

    await localCache.saveComments(questionId, initialComments);
    return initialComments;
  }

  @override
  Future<void> addComment(QuestionComment comment) async {
    final comments = await getComments(comment.questionId);
    comments.add(comment);
    await localCache.saveComments(comment.questionId, comments);
  }

  @override
  Future<void> updateComment(
    QuestionComment comment, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    final comments = await getComments(comment.questionId);
    final index = comments.indexWhere((c) => c.id == comment.id);
    if (index >= 0) {
      final existing = comments[index];
      // 嚴格權限檢查：只有原作者本人或系統管理員可以修改留言！
      if (!existing.canEdit(currentUid: currentUserId, isAdmin: isAdmin)) {
        throw Exception('【權限不足】：您不是此留言的原作者，僅能進行讀取，無法修改他人發布之留言！');
      }
      comments[index] = comment.copyWith(updatedAt: DateTime.now());
      await localCache.saveComments(comment.questionId, comments);
    }
  }

  @override
  Future<void> deleteComment(
    String commentId,
    String questionId, {
    required String currentUserId,
    bool isAdmin = false,
  }) async {
    final comments = await getComments(questionId);
    final index = comments.indexWhere((c) => c.id == commentId);
    if (index >= 0) {
      final existing = comments[index];
      // 嚴格權限檢查：只有原作者本人或系統管理員可以刪除留言！
      if (!existing.canEdit(currentUid: currentUserId, isAdmin: isAdmin)) {
        throw Exception('【權限不足】：您不是此留言的原作者，無法刪除他人的討論區留言！');
      }
      comments.removeAt(index);
      await localCache.saveComments(questionId, comments);
    }
  }
}
