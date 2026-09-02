import 'package:http/http.dart' as http;

class NtpTimeHelper {
  NtpTimeHelper._();

  /// 透過 Google 雲端時間 API 檢驗真實網路時間
  static Future<DateTime> getNetworkTime() async {
    try {
      final response = await http.head(Uri.parse('https://www.google.com')).timeout(
        const Duration(seconds: 3),
      );
      final dateHeader = response.headers['date'];
      if (dateHeader != null) {
        return DateTime.parse(dateHeader);
      }
    } catch (_) {
      // 斷網或逾時時回退至本地時間
    }
    return DateTime.now();
  }

  /// 驗證本地時間是否被竄改 (超過 5 分鐘偏差)
  static Future<bool> isSystemTimeTampered() async {
    try {
      final netTime = await getNetworkTime();
      final localTime = DateTime.now();
      final diffSeconds = netTime.difference(localTime).inSeconds.abs();
      return diffSeconds > 300; // 偏差大於 5 分鐘
    } catch (_) {
      return false;
    }
  }
}
