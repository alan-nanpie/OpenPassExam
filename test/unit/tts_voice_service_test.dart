import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/services/tts_voice_service.dart';

void main() {
  group('TtsVoiceService Tests', () {
    test('應該正確執行語音朗讀、暫停與停止操作', () async {
      final tts = TtsVoiceService();

      expect(tts.isPlaying, isFalse);
      expect(tts.currentText, isEmpty);

      await tts.speak('題目：OSPF 是什麼協定？');
      expect(tts.isPlaying, isTrue);
      expect(tts.currentText, '題目：OSPF 是什麼協定？');

      await tts.pause();
      expect(tts.isPlaying, isFalse);
      expect(tts.currentText, '題目：OSPF 是什麼協定？');

      await tts.stop();
      expect(tts.isPlaying, isFalse);
      expect(tts.currentText, isEmpty);
    });
  });
}
