# 🚀 Google Cloud Run 一鍵自動化發布與零基礎實戰指南

> **適用對象：** 從完全沒碰過程式碼的電腦初學者，到需要調校架構的專業 DevOps 工程師。  
> **專案特性：** 100% 機密分離設計。本專案為 GitHub 公開開源倉庫，本教學確保**任何個人專案 ID、金鑰與憑證絕對不會洩漏至 GitHub**，人人皆可安心使用與自我體驗！

---

## 📖 目錄導覽

- [🌟 為什麼選擇 Google Cloud Run？](#-為什麼選擇-google-cloud-run)
- [🌱 第一篇：小白新手篇（零基礎，3 步驟一鍵發布）](#-第一篇小白新手篇零基礎3-步驟一鍵發布)
  - [步驟 1：準備 Google 帳號與安裝 Google 雲端工具](#步驟-1準備-google-帳號與安裝-google-雲端工具)
  - [步驟 2：取得專案程式碼](#步驟-2取得專案程式碼)
  - [步驟 3：一鍵執行自動發布程式](#步驟-3一鍵執行自動發布程式)
- [🛡️ 第二篇：資安與機密分離篇（為什麼公開在 GitHub 也能 100% 安全？）](#️-第二篇資安與機密分離篇為什麼公開在-github-也能-100-安全)
- [⚙️ 第三篇：進階客製篇（自訂地區、效能升級與獨立網域）](#️-第三篇進階客製篇自訂地區效能升級與獨立網域)
- [📊 第四篇：企業維運篇（成本守門員、日誌監控與版本管理）](#-第四篇企業維運篇成本守門員日誌監控與版本管理)

---

## 🌟 為什麼選擇 Google Cloud Run？

1. **完全免管理伺服器（Serverless）**：你不需要去買主機、安裝 Linux 或擔心主機當機，Google 會自動替你管理運算資源。
2. **極致省錢甚至完全免費**：Google Cloud Run 每個月提供**前 200 萬次請求免費**。沒人訪問時自動縮容到 0 台機器（完全不計費），有人訪問時瞬間喚醒！
3. **自帶全球 CDN 與安全 HTTPS 綠色鎖頭**：發布成功後立即獲得一組 Google 官方配發的專屬網址，自動包含最高規格 SSL 安全加密憑證。

---

## 🌱 第一篇：小白新手篇（零基礎，3 步驟一鍵發布）

即使您從未寫過任何一行程式碼，只要按照以下 3 個步驟，大約 5 到 10 分鐘，您就能擁有一個專屬於您自己或您企業的 PassExam 線上題庫平台！

### 步驟 1：準備 Google 帳號與安裝 Google 雲端工具

1. **登入 Google Cloud 控制台**：
   - 使用您的 Google 帳號開啟 [Google Cloud Console (console.cloud.google.com)](https://console.cloud.google.com/)。
   - 首次登入請建立一個新專案（例如名稱取名為 `my-passexam-app`），並記下系統分配給您的 **專案 ID (Project ID)**（例如：`my-passexam-app-123456`）。
2. **安裝 Google Cloud CLI (gcloud 命令行工具)**：
   - 前往 Google 官方下載頁：👉 [下載 Google Cloud CLI 安裝程式 (Windows)](https://cloud.google.com/sdk/docs/install#windows)
   - 下載完成後，點擊安裝檔，一路點擊「下一步 (Next)」直到完成。
   - 安裝完成後，開啟電腦的 PowerShell（在 Windows 開始選單搜尋 `powershell` 開啟），輸入以下指令登入您的 Google 帳號：
     ```powershell
     gcloud auth login
     ```
     *(瀏覽器會自動彈出登入視窗，點擊「允許」即可完成登入)*。

---

### 步驟 2：取得專案程式碼

1. 前往 GitHub 公開專案頁面：[https://github.com/alan-nanpie/OpenPassExam](https://github.com/alan-nanpie/OpenPassExam)
2. 點擊右上角綠色按鈕 **`Code`** ➔ 選擇 **`Download ZIP`**。
3. 下載後解壓縮到您的電腦（例如解壓縮到 `C:\OpenPassExam` 或桌面）。

---

### 步驟 3：一鍵執行自動發布程式

本專案特別打造了**零基礎智慧發布腳本**，您**本機電腦不需要安裝 Docker，也不需要安裝 Flutter**，所有繁重的編譯與打包工作全部交由 Google 雲端超級電腦自動完成！

1. 在專案資料夾空白處，按住鍵盤的 `Shift` 鍵並按滑鼠右鍵，選擇 **「在終端機中開啟」** 或 **「在此處開啟 PowerShell 視窗」**。
2. 在視窗中輸入以下指令並按下 `Enter`：
   ```powershell
   .\deploy.ps1
   ```
   *(或者執行 `.\scripts\deploy_cloud_run.ps1`)*

3. **友善中文引導（只有第一次需要輸入）**：
   - 腳本會自動偵測您的環境。若尚未設定專案，畫面會顯示：
     ```text
     請輸入您在 Google Cloud 建立的專案 ID (Project ID)：
     GCP Project ID: my-passexam-app-123456
     ```
   - 貼上您在步驟 1 取得的專案 ID，並按下 `Enter`。
   - 腳本會貼心詢問：`是否將專案 ID 儲存至本地 scripts/deploy.env？(Y/n)`，直接按下 `Enter`（預設為 Yes）。
   - **完成！** 接下來腳本會全自動執行：
     - `[1/5]` 自動啟用 Google Cloud 必要雲端 API
     - `[2/5]` 自動建立 Artifact Registry 容器庫
     - `[3/5]` 透過 Google Cloud Build 在雲端建置最新 Docker 映像檔
     - `[4/5]` 自動部署至 Cloud Run 伺服器
     - `[5/5]` 輸出您的專屬正式上線網址！

4. **發布成功！**
   終端機最後會顯示綠色訊息：
   ```text
   🎉 ========================================================
   ✨ 恭喜！PassExam Web 版已成功部署至 Google Cloud Run！
   🌐 正式服務網址 (URL):
      https://passexam-web-xxxxxxxx.asia-east1.run.app
   ========================================================
   ```
   複製這個網址貼到瀏覽器，您的 PassExam 考題與 AI 助教平台就正式對外運作了！

---

## 🛡️ 第二篇：資安與機密分離篇（為什麼公開在 GitHub 也能 100% 安全？）

很多新手或企業常問：「**專案在 GitHub 上是完全公開的開源倉庫，我執行腳本會不會不小心把我的 GCP 帳號或專案 ID 上傳給全世界看？**」

答案是：**絕對不會！我們採用了業界最高標準的「機密分離架構 (Secrets Decoupling)」**。

### 1. 三重安全防禦隔離機制

```text
┌─────────────────────────────────────────────────────────────┐
│ 📁 專案根目錄                                                │
│                                                             │
│   ├── scripts/deploy.env.example ───► [公開] 提交至 GitHub    │
│   │   (只有空白範本與說明，不含任何真實資訊)                   │
│   │                                                         │
│   ├── scripts/deploy.env ───────────► [私密] 僅存在您的電腦   │
│   │   (存放您的真實專案 ID: GCP_PROJECT_ID=xxx)               │
│   │                                                         │
│   └── 🛡️ .gitignore / .dockerignore / .gcloudignore         │
│       (嚴格封鎖 deploy.env 上傳至任何遠端平台)                  │
└─────────────────────────────────────────────────────────────┘
```

1. **第一重防護：`.gitignore` 原始碼管制隔離**：
   - 設定檔 `scripts/deploy.env`、`*.env` 已寫入 `.gitignore`，Git 永遠不會追蹤該檔案，即使您執行 `git add .` 與 `git push`，機密設定檔也絕不可能被推送到 GitHub！
2. **第二重防護：`.gcloudignore` 雲端打包隔離**：
   - 當代碼發送給 Google Cloud Build 雲端打包時，`.gcloudignore` 會自動剔除私有 `.env` 與文件，避免上傳至雲端暫存儲存庫。
3. **第三重防護：`.dockerignore` 容器鏡像隔離**：
   - 容器映像檔只包含編譯後的純 HTML/JS 靜態檔案，絕不打包任何本機金鑰或環境設定。

### 2. BYOK (Bring Your Own Key) 金鑰隔離
- 本專案採用最新 **BYOK 架構**，AI 金鑰是由每一位終端使用者在網頁上各自輸入自己的免費 Google AI Studio Key，保存在使用者手機/瀏覽器的 LocalStorage 中。
- **伺服器端完全不需要託管任何全域金鑰**，徹底杜絕帳單盜刷或金鑰外洩問題！

---

## ⚙️ 第三篇：進階客製篇（自訂地區、效能升級與獨立網域）

如果您具備基礎開發能力，或希望為公司內部團隊進行客製化調校，您可以透過編輯 `scripts/deploy.env` 來調整各項參數：

### 1. 修改 `scripts/deploy.env` 參數

```bash
# 【必填】您的 GCP 專案 ID
GCP_PROJECT_ID=my-custom-project-id

# 【選填】部署地區 (Region)
# 台灣: asia-east1 (延遲最低，推薦台灣使用者)
# 日本東京: asia-northeast1
# 美國中部: us-central1 (成本極低)
GCP_REGION=asia-east1

# 【選填】服務名稱
SERVICE_NAME=passexam-web

# 【選填】容器庫名稱
REPO_NAME=passexam-repo

# 【選填】記憶體限制 (預設 512Mi，多人高併發可調大至 1Gi 或 2Gi)
MEMORY_LIMIT=512Mi

# 【選填】CPU 核心數 (預設 1)
CPU_LIMIT=1
```

編輯儲存後，再次執行 `.\deploy.ps1`，腳本會自動讀取最新設定並進行滾動更新！

---

### 2. 綁定公司或個人自訂網域 (Custom Domain)

如果您想使用自己的網域名稱（例如：`exam.yourdomain.com`）：

1. 開啟 [Google Cloud Run 控制台](https://console.cloud.google.com/run)。
2. 點擊您的服務 `passexam-web`。
3. 點擊頂部 **「管理自訂網域 (Manage Custom Domains)」** ➔ 點擊 **「新增對應」**。
4. 輸入您的網域名稱（如 `exam.yourdomain.com`）。
5. 按照 Google 給出的提示，在您的 DNS 代管商（如 Cloudflare、GoDaddy 等）加入一筆 `CNAME` 或 `A` 紀錄。
6. 設定完成後，Google Cloud Run 會在 10 分鐘內自動替您申請好免費的 SSL 憑證！

---

## 📊 第四篇：企業維運篇（成本守門員、日誌監控與版本管理）

### 1. 成本預算守門員（防止意外扣款）
Google Cloud Run 本身費用極為便宜，但為了 100% 安心，建議設定「預算警報」：
1. 進入 [GCP 帳單預算與警報 (Budgets & Alerts)](https://console.cloud.google.com/billing/budgets)。
2. 點擊「建立預算」，設定每月預算（例如 \$100 元新台幣或 \$1 美元）。
3. 勾選「達到 50%、90%、100% 時發送電子郵件通知」。這樣一旦接近扣款門檻，您會第一時間收到信件，絕無意外費用！

---

### 2. 查看線上即時日誌與效能 (Cloud Logging)
當使用者回報問題時，您可以即時監控：
1. 前往 Cloud Run 控制台點擊 `passexam-web`。
2. 點擊 **「記錄 (Logs)」** 分頁，可以即時看到全球考生的 HTTP 請求與系統運作狀態。
3. 點擊 **「指標 (Metrics)」** 分頁，可查看每秒請求數 (RPS)、伺服器回應延遲時間 (Latency) 與記憶體使用率圖表。

---

### 3. 一鍵版本回滾 (Rollback)
如果更新後發現新版有問題，想退回上一版：
```powershell
# 列出歷史發布版本
gcloud run revisions list --service passexam-web --region asia-east1

# 一鍵將流量切回指定舊版本
gcloud run services update-traffic passexam-web --to-revisions passexam-web-00002-xxx=100 --region asia-east1
```

---

### 4. 徹底銷毀與清理資源
若未來不再需要使用此服務，執行以下指令即可安全刪除，完全停止計費：
```powershell
# 刪除 Cloud Run 服務
gcloud run services delete passexam-web --region asia-east1 --quiet

# 刪除 Artifact Registry 映像庫
gcloud artifacts repositories delete passexam-repo --location asia-east1 --quiet
```

---

## 🎯 總結：給所有開發者與使用者的話

本自動化發布程式將現代雲端 DevOps 的所有最佳實踐（容器化、無伺服器架構、機密與原始碼分離、自動化構建管線）包裝成了簡單易用的小工具：
- **對新手：** 不需要知道 Docker 怎麼寫、不需要知道 Nginx 怎麼配，輸入專案 ID 就能一鍵上線。
- **對開源貢獻者：** 程式碼推送到 GitHub 完全透明開源，無需擔心個人帳戶與私密設定遭到追蹤。

歡迎大家 Fork 體驗，打造屬於您自己的全球化雲端考題平台！🎉
