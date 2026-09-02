# 05. 安全架構 (Security Architecture)

## 1. 三位一體防護矩陣 (Triple-Defense Matrix)
1. **動態個人化浮水印 (`EnhancedSecurityWatermark`)**:
   - 8 列 4 欄以 45 度旋轉傾斜疊加使用者 UID、姓名與當前時間戳記。
2. **原生安全鎖定 (`SecureScreenService`)**:
   - 啟用 Android 原生層 `FLAG_SECURE`，防截圖、防螢幕錄影、防 HDMI 投影。
3. **Web 安全封裝 (`WebSecurityWrapper`)**:
   - 禁用右鍵選單、禁用文字選取與複製、監控 DevTools 審查工具開啟。

## 2. 雲端安全防護
- **Firebase App Check & Google Play Integrity**: 驗證請求來自合法的 Android 應用程式。
- **Firestore Security Rules**: 基於 Firebase Auth Custom Claims 限制題目讀寫權限。
