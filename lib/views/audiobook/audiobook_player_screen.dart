import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/exam_controller.dart';
import '../../services/tts_voice_service.dart';

class AudiobookPlayerScreen extends StatefulWidget {
  final String subjectId;

  const AudiobookPlayerScreen({super.key, required this.subjectId});

  @override
  State<AudiobookPlayerScreen> createState() => _AudiobookPlayerScreenState();
}

class _AudiobookPlayerScreenState extends State<AudiobookPlayerScreen> {
  final TtsVoiceService _ttsService = TtsVoiceService();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examCtrl = context.read<ExamController>();
      if (examCtrl.currentSubjectId != widget.subjectId || examCtrl.questions.isEmpty) {
        examCtrl.loadQuestionsForSubject(widget.subjectId);
      }
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  void _togglePlayPause() async {
    final examCtrl = context.read<ExamController>();
    final q = examCtrl.currentQuestion;
    if (q == null) return;

    if (_isPlaying) {
      await _ttsService.pause();
      setState(() => _isPlaying = false);
    } else {
      final textToRead = '題目：${q.title}。正確答案為選項 ${q.correctAnswer.map((i) => String.fromCharCode(65 + i)).join(", ")}。詳解：${q.explanationZhTw ?? q.explanation}';
      await _ttsService.speak(textToRead);
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final examCtrl = context.watch<ExamController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = examCtrl.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('audiobook_title')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 唱盤動畫展示卡片
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: _isPlaying ? 0.4 : 0.1),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: const Icon(Icons.headphones, size: 40, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Text(
                  'Cisco ${widget.subjectId} 考題有聲導讀',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  q != null
                      ? '第 ${examCtrl.currentIndex + 1} 題 / 共 ${examCtrl.questions.length} 題 - ${q.topic}'
                      : '準備中...',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // 考題內容簡閱卡片
                if (q != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                    ),
                    child: Text(
                      q.title,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32),

                // 播放控制列
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.skip_previous),
                      onPressed: examCtrl.currentIndex > 0
                          ? () {
                              examCtrl.previousQuestion();
                              if (_isPlaying) _togglePlayPause();
                            }
                          : null,
                    ),
                    const SizedBox(width: 20),
                    IconButton.filled(
                      iconSize: 48,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.skip_next),
                      onPressed: examCtrl.currentIndex < examCtrl.questions.length - 1
                          ? () {
                              examCtrl.nextQuestion();
                              if (_isPlaying) _togglePlayPause();
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
