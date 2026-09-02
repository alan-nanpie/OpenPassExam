import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/views/mock_exam/exam_timer_widget.dart';

void main() {
  group('ExamTimerWidget Tests', () {
    testWidgets('應該依照 ValueNotifier 動態更新時間且支援局部重繪', (tester) async {
      final notifier = ValueNotifier<int>(3600); // 60:00

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExamTimerWidget(remainingSecondsNotifier: notifier),
          ),
        ),
      );

      expect(find.text('60:00'), findsOneWidget);

      // 更新秒數至 59:30
      notifier.value = 3570;
      await tester.pump();

      expect(find.text('59:30'), findsOneWidget);
    });
  });
}
