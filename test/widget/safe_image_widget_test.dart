import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/core/widgets/safe_image_widget.dart';

void main() {
  group('SafeImageWidget Widget Tests', () {
    testWidgets('空網址時應顯示預設佔位圖示且不引發崩潰', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SafeImageWidget(imageUrl: null),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.text('暫無考題拓撲圖'), findsOneWidget);
    });
  });
}
