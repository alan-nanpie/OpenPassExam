# Google AdMob Setup Guide

## 1. Account & Project Setup
- Navigate to the [Google AdMob](https://admob.google.com/) console.
- Create ad units:
  - **Banner Ad**: `passexam_bottom_banner`
  - **Interstitial Ad**: `passexam_exam_completion_interstitial`
  - **Rewarded Ad**: `passexam_unlock_ai_hint_rewarded`

## 2. SDK Installation
```yaml
dependencies:
  google_mobile_ads: ^5.2.0
```

## 3. Android Configuration (`android/app/src/main/AndroidManifest.xml`)
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
    </application>
</manifest>
```

## 4. Code Integration
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void initAdMob() {
  MobileAds.instance.initialize();
}
```
