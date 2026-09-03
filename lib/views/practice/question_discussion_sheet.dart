import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/discussion_controller.dart';
import '../../data/models/question.dart';
import '../../data/models/question_comment.dart';

class QuestionDiscussionSheet extends StatefulWidget {
  final Question question;

  const QuestionDiscussionSheet({super.key, required this.question});

  static void show(BuildContext context, Question question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuestionDiscussionSheet(question: question),
    );
  }

  @override
  State<QuestionDiscussionSheet> createState() => _QuestionDiscussionSheetState();
}

class _QuestionDiscussionSheetState extends State<QuestionDiscussionSheet> {
  final TextEditingController _commentInputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscussionController>().loadComments(widget.question.id);
    });
  }

  @override
  void dispose() {
    _commentInputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final discussionCtrl = context.watch<DiscussionController>();
    final authCtrl = context.watch<AuthController>();
    final currentUser = authCtrl.currentUser;
    final comments = discussionCtrl.getCommentsForQuestion(widget.question.id);

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 頂部拖曳把手與標題
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.forum_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '考題討論區 (${comments.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '題目：${widget.question.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 留言清單
          Expanded(
            child: discussionCtrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            const Text('目前尚無討論，成為第一個分享解題思路的學員吧！', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        separatorBuilder: (_, _) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final c = comments[index];
                          final isMyComment = c.isAuthor(currentUser?.uid);
                          final canManage = isMyComment || (currentUser?.isAdmin ?? false);

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isMyComment
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkCard : const Color(0xFFE8F0FE)),
                                child: Text(
                                  c.authorName.isNotEmpty ? c.authorName.characters.first : 'U',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isMyComment ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          c.authorName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                        ),
                                        const SizedBox(width: 6),
                                        if (isMyComment)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              '本人',
                                              style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        const Spacer(),
                                        Text(
                                          _formatTimestamp(c.createdAt),
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                        if (canManage)
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
                                            padding: EdgeInsets.zero,
                                            onSelected: (val) {
                                              if (val == 'edit') {
                                                _showEditCommentDialog(context, discussionCtrl, c, currentUser?.uid ?? '');
                                              } else if (val == 'delete') {
                                                _confirmDeleteComment(context, discussionCtrl, c, currentUser?.uid ?? '');
                                              }
                                            },
                                            itemBuilder: (ctx) => [
                                              const PopupMenuItem(value: 'edit', child: Text('編輯留言')),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('刪除留言', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c.content,
                                      style: const TextStyle(fontSize: 13.5, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),

          // 底部發表留言區塊
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentInputController,
                    focusNode: _focusNode,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: currentUser == null
                          ? '請先登入後發表討論'
                          : '分享您的考題思考或疑惑...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send, size: 18),
                  onPressed: () async {
                    final text = _commentInputController.text.trim();
                    if (text.isEmpty) return;

                    final success = await discussionCtrl.addComment(
                      questionId: widget.question.id,
                      examId: widget.question.examId,
                      authorId: currentUser?.uid ?? 'guest',
                      authorName: currentUser?.displayName ?? '匿名考生',
                      authorRole: currentUser?.role.name ?? 'viewer',
                      content: text,
                    );

                    if (success) {
                      _commentInputController.clear();
                      _focusNode.unfocus();
                    } else if (context.mounted && discussionCtrl.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(discussionCtrl.errorMessage!)),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(
    BuildContext context,
    DiscussionController ctrl,
    QuestionComment comment,
    String currentUserId,
  ) {
    final editController = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('編輯留言'),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newContent = editController.text.trim();
              if (newContent.isNotEmpty) {
                final success = await ctrl.updateComment(
                  comment: comment.copyWith(content: newContent),
                  currentUserId: currentUserId,
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (!success && context.mounted && ctrl.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ctrl.errorMessage!)),
                  );
                }
              }
            },
            child: const Text('儲存'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteComment(
    BuildContext context,
    DiscussionController ctrl,
    QuestionComment comment,
    String currentUserId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('刪除留言確認'),
        content: const Text('確定要刪除這則討論留言嗎？此動作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ctrl.deleteComment(
                commentId: comment.id,
                questionId: comment.questionId,
                currentUserId: currentUserId,
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (!success && context.mounted && ctrl.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ctrl.errorMessage!)),
                );
              }
            },
            child: const Text('刪除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '剛剛';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分鐘前';
    if (diff.inHours < 24) return '${diff.inHours} 小時前';
    return '${dt.month}/${dt.day}';
  }
}
