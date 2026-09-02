import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/core/widgets/enhanced_security_watermark.dart';

void main() {
  group('EnhancedSecurityWatermark Widget Tests', () {
    testWidgets('應該正確包裝子 Widget 並覆蓋動態浮水印', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EnhancedSecurityWatermark(
              userId: 'usr_test_9999',
              userName: 'Test Engineer',
              child: Text('Protected Exam Content'),
            ),
          ),
        ),
      );

      expect(find.text('Protected Exam Content'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
