# Google AdMob 設定指南

## 1. 帳號與專案設定
- 前往 [Google AdMob](https://admob.google.com/) 控制台建立應用程式。
- 建立廣告單元：
  - **橫幅廣告 (Banner)**：`passexam_bottom_banner`
  - **插頁式廣告 (Interstitial)**：`passexam_exam_completion_interstitial`
  - **獎勵廣告 (Rewarded)**：`passexam_unlock_ai_hint_rewarded`

## 2. SDK 安裝
```yaml
dependencies:
  google_mobile_ads: ^5.2.0
```

## 3. Android 配置 (`android/app/src/main/AndroidManifest.xml`)
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
    </application>
</manifest>
```

## 4. 程式碼整合
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void initAdMob() {
  MobileAds.instance.initialize();
}
```
