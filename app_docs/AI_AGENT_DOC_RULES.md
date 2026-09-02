# AI Agent 文檔維護規範 (AI Agent Documentation Rules)

本文件定義所有 AI Agent（包含 Antigravity, GitHub Copilot, Gemini CLI, Claude 等）在協助維護、擴充與更新 **PassExam** 專案時，必須強制遵循的文檔存放與維護規則。

---

## 📌 核心規則 (Core Directives)

### 規則 1：所有安裝、建置與使用手冊一律集中於 `app_docs/`
- **範圍定義**：
  - 專案或 App 的安裝教學 (Installation Guides)
  - 平台建置與編譯說明 (Build & Compilation Guides)
  - 使用者操作手冊 (User Manuals / Beginner Guides)
  - 雲端與伺服器部署步驟 (Deployment & Operations)
  - 常見問答與疑難排解 (Troubleshooting & FAQs)
- **要求**：未來任何新增或修訂上述性質之 Markdown 文件，**強制只能放在 `app_docs/` 目錄**，嚴禁在專案根目錄散落各類手冊。

### 規則 2：繁體中文（台灣標準 zh-TW）原則
- 繁體中文文檔嚴格遵守台灣慣用網路與軟體術語：
  - ✅ 伺服器 (Server)、✅ 連接埠 (Port)、✅ 存放庫/儲存庫 (Repository)
  - ✅ 路由 (Routing)、✅ 封包 (Packet)、✅ 交換器 (Switch)
  - ❌ 禁絕使用大陸非繁體中文術語。

### 規則 3：安全與機密嚴格零容忍 (Zero-Leakage Policy)
- 任何文檔或腳本中，**絕對不得寫入或洩漏**：
  - 實際的 API 金鑰 (API Keys, Token)
  - 服務帳戶私密憑證 (Service Account JSON)
  - 簽章金鑰密碼 (Keystore passwords, `key.properties`)
  - 使用者個人隱私資料
- 必須一律採用環境變數、GCP Secret Manager 或預留佔位符（如 `YOUR_PROJECT_ID`、`YOUR_API_KEY`）表示。
