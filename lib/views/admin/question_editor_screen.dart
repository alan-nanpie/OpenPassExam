import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/exam_subjects_data.dart';
import '../../controllers/admin_controller.dart';
import '../../data/models/question.dart';

class QuestionEditorScreen extends StatefulWidget {
  final Question? initialQuestion;

  const QuestionEditorScreen({super.key, this.initialQuestion});

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  String _subjectId = 'cisco-200-301';
  String _type = 'SINGLE_CHOICE';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _explanationController = TextEditingController();
  final TextEditingController _explanationZhTwController = TextEditingController();
  final TextEditingController _explanationJaController = TextEditingController();
  final TextEditingController _grammarNotesController = TextEditingController();

  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final Set<int> _correctAnswers = {0};

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuestion;
    if (q != null) {
      _subjectId = q.examId;
      _type = q.type;
      _titleController.text = q.title;
      _topicController.text = q.topic;
      _imageUrlController.text = q.imageUrl ?? '';
      _explanationController.text = q.explanation;
      _explanationZhTwController.text = q.explanationZhTw ?? '';
      _explanationJaController.text = q.explanationJa ?? '';
      _grammarNotesController.text = q.englishGrammarNotes ?? '';

      _optionControllers.clear();
      for (final opt in q.options) {
        _optionControllers.add(TextEditingController(text: opt));
      }
      _correctAnswers.clear();
      _correctAnswers.addAll(q.correctAnswer);
    } else {
      _topicController.text = '1.0 網路基礎';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _imageUrlController.dispose();
    _explanationController.dispose();
    _explanationZhTwController.dispose();
    _explanationJaController.dispose();
    _grammarNotesController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminCtrl = context.watch<AdminController>();

    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 所屬科目與題型
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _subjectId,
                    decoration: const InputDecoration(labelText: '考科選擇'),
                    items: ExamSubjectsData.allSubjects.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(s.code, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _subjectId = v ?? 'cisco-200-301'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: '題型'),
                    items: const [
                      DropdownMenuItem(value: 'SINGLE_CHOICE', child: Text('單選題')),
                      DropdownMenuItem(value: 'MULTIPLE_CHOICE', child: Text('複選題')),
                      DropdownMenuItem(value: 'DRAG_DROP', child: Text('拖曳配對')),
                      DropdownMenuItem(value: 'SIMULATION', child: Text('實作模擬')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'SINGLE_CHOICE'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 考點領域
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: '考點領域 (Topic / Domain)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? '請輸入考點領域' : null,
            ),
            const SizedBox(height: 14),

            // 題目本文
            TextFormField(
              controller: _titleController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '題目本文 (Question Title)',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? '請輸入題目本文' : null,
            ),
            const SizedBox(height: 14),

            // 拓撲圖片 URL
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: '考題拓撲圖片 URL (選填)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 18),

            // 選項配置與正確答案標註
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('考題選項清單 (點擊勾選正確答案)', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('新增選項'),
                  onPressed: () {
                    setState(() {
                      _optionControllers.add(TextEditingController());
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...List.generate(_optionControllers.length, (idx) {
              final isCorrect = _correctAnswers.contains(idx);
              final optChar = String.fromCharCode(65 + idx);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isCorrect ? AppColors.correctGreen : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_type == 'SINGLE_CHOICE' || _type == 'SIMULATION') {
                            _correctAnswers.clear();
                            _correctAnswers.add(idx);
                          } else {
                            if (_correctAnswers.contains(idx)) {
                              _correctAnswers.remove(idx);
                            } else {
                              _correctAnswers.add(idx);
                            }
                          }
                        });
                      },
                    ),
                    Text('$optChar. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: TextFormField(
                        controller: _optionControllers[idx],
                        decoration: InputDecoration(
                          hintText: '選項 $optChar 內容',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // 官方詳解 (多語系)
            TextFormField(
              controller: _explanationZhTwController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '繁體中文詳解 (台灣標準網路術語)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _explanationController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'English Official Explanation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _grammarNotesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '從考題學英文文法與關鍵字解析',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 儲存按鈕
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('儲存考題並同步至 Firestore 集合', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final options = _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
                    if (options.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❌ 請至少輸入一個考題選項')),
                      );
                      return;
                    }

                    final newQuestion = Question(
                      id: widget.initialQuestion?.id ?? 'q_${const Uuid().v4().substring(0, 8)}',
                      examId: _subjectId,
                      type: _type,
                      title: _titleController.text.trim(),
                      options: options,
                      correctAnswer: _correctAnswers.toList()..sort(),
                      explanation: _explanationController.text.trim(),
                      explanationZhTw: _explanationZhTwController.text.trim(),
                      explanationJa: _explanationJaController.text.trim(),
                      topic: _topicController.text.trim(),
                      imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
                      isApproved: true,
                      englishGrammarNotes: _grammarNotesController.text.trim(),
                    );

                    await adminCtrl.saveQuestion(
                      subjectId: _subjectId,
                      question: newQuestion,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ 考題已成功儲存！')),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
