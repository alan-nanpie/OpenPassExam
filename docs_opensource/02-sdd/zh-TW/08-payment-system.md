# 08. 付款與訂閱系統 (Payment System)

## 1. Google Play Billing 原生官方架構
PassExam 全面採用 Google Play Billing（Play Billing Library 6+）管理應用程式內購與訂閱：
- **方案等級**: 月費 (`passexam_pro_monthly`)、季費 (`passexam_pro_quarterly`)、年費 (`passexam_pro_annual`)。
- **即時通知 (RTDN)**: 透過 Google Cloud Pub/Sub 接收 Google Play 訂閱續訂、取消與退款事件。
- **後端安全驗證**: Firebase Cloud Functions 呼叫 Google Play Developer API 驗證購買收據。
