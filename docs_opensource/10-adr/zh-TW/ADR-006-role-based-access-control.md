# ADR-006: 基於角色的存取控制 (Role-Based Access Control)
## 狀態: 已接受 (Accepted)
## 日期: 2026-09-01
## 背景 (Context)
系統需要支援多種使用者角色（訪客、待審核者、檢視者、內部測試人員、公開測試人員、管理員）的細緻權限控管。

## 決策 (Decision)
採用 Firebase Auth Custom Claims 結合 Cloud Firestore Security Rules 實施 RBAC 架構：
- 權限宣告存於 Firebase Auth JWT 權杖中，客戶端與雲端安全性規則同步驗證。
- 管理員角色可存取「🤖 AI 模型與 Remote Config 管理」與題庫批次審核控制台。
