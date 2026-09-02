import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/core/utils/compute_helper.dart';

void main() {
  group('ComputeHelper ANR Safeguard Tests', () {
    test('大文字與日誌串接應能正確在背景執行處理', () async {
      final input = List.generate(600, (i) => 'Line $i: OSPF packet checksum valid').join('\n');
      final output = await ComputeHelper.processLargeString(input);
      expect(output.contains('Line 599: OSPF packet checksum valid'), true);
    });

    test('RAG 切片格式化應能正確生成 Markdown 結構', () async {
      final rawChunks = [
        {
          'bookTitle': 'CCNA 200-301 Cert Guide',
          'pageNumber': 100,
          'chapter': 'Ch 5',
          'topic': 'VLANs and Trunks',
          'content': '802.1Q encapsulation adds a 4-byte tag to the Ethernet frame.',
        }
      ];

      final formatted = await ComputeHelper.formatRagKnowledgeChunks(rawChunks);
      expect(formatted.contains('CCNA 200-301 Cert Guide'), true);
      expect(formatted.contains('802.1Q encapsulation'), true);
    });
  });
}
