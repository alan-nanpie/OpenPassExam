# ADR-005: 三位一體防側錄與縱深防禦安全架構 (Security-First Design)
## 狀態: 已接受 (Accepted)
## 日期: 2026-09-01
## 背景 (Context)
專業認證考題與知識庫具備高商業與智慧財產價值，必須防範截圖、側錄與惡意洩漏。

## 決策 (Decision)
實施企業級三位一體安全防護矩陣：
1. **動態浮水印 (`EnhancedSecurityWatermark`)**: 8 列 4 欄個人化 UID/時間戳記動態疊加，防實體相機拍攝。
2. **原生安全鎖定 (`SecureScreenService`)**: Android 原生層 `FLAG_SECURE` 防截圖、防螢幕錄影、防投屏。
3. **Web 安全封裝 (`WebSecurityWrapper`)**: 禁用右鍵選單、禁用複製剪貼簿、DevTools 開發者工具監控。
4. **Google Play Integrity & App Check**: 保護雲端 API 免受未授權客戶端調用。
