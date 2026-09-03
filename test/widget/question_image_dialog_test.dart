import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/core/widgets/question_image_reference_dialog.dart';
import 'package:passexam/data/models/question.dart';

void main() {
  testWidgets('QuestionImageReferenceDialog 應該正確渲染上下分屏與考題文字', (tester) async {
    final testQuestion = Question(
      id: 'test_q001',
      examId: 'cisco-200-301',
      type: 'SINGLE_CHOICE',
      title: '請依據下方網路拓撲圖回答 OSPF 鄰居建立問題',
      options: ['選項 A', '選項 B', '選項 C', '選項 D'],
      correctAnswer: [0],
      explanation: '這是詳細官方解析內容。',
      topic: '3.0 IP 連線能力',
      imageUrl: 'https://example.com/topology.png',
      isApproved: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => QuestionImageReferenceDialog.show(context, testQuestion),
              child: const Text('開啟分屏對照'),
            ),
          ),
        ),
      ),
    );

    // 點擊按鈕開啟 Dialog
    await tester.tap(find.text('開啟分屏對照'));
    await tester.pumpAndSettle();

    // 驗證標題與考題文字
    expect(find.text('上下分屏圖文對照檢視'), findsOneWidget);
    expect(find.text('請依據下方網路拓撲圖回答 OSPF 鄰居建立問題'), findsOneWidget);

    // 點擊關閉按鈕關閉 Dialog
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('上下分屏圖文對照檢視'), findsNothing);
  });
}
