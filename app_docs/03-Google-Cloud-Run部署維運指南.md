# PassExam Google Cloud Run 部署與維運指南 ☁️

本文件說明如何將 PassExam Web 版容器化並部署至 Google Cloud Run，包含架構細節、安全防護與自動化維運流程。

---

## 🏛️ 1. 容器架構設計 (Container Architecture)

PassExam 採用 **多階段建置 (Multi-stage Build)**，兼顧建置完整性與執行期極致輕量化：

1. **建置階段 (Build Stage)**：
   - 映像檔：`ghcr.io/cirruslabs/flutter:stable`
   - 作業：下載 pub 依賴，執行 `flutter build web --release`，產生 Web 靜態資源。
2. **執行階段 (Runtime Stage)**：
   - 映像檔：`nginx:alpine`（體積僅約 20MB）
   - 配置：專屬 `nginx.conf`，支援 SPA 路由回退、Gzip 壓縮、WASM/JS 快取、安全標頭，監聽 `8080` 埠號。

---

## 🚀 2. 部署操作方式

### 方式 A：一鍵 PowerShell 自動化發布（推薦）
在專案根目錄直接執行：
```powershell
./scripts/deploy_cloud_run.ps1
```
> **腳本自動完成**：
> 1. 檢查當前 GCP 專案。
> 2. 啟用 Cloud Run, Artifact Registry, Cloud Build APIs。
> 3. 建立 Artifact Registry 存放區（若不存在）。
> 4. 使用 Cloud Build 於雲端建置並推送 Docker 映像檔。
> 5. 發布至 Cloud Run 並印出公開網址。

---

### 方式 B：手動 CLI 指令逐步部署
```bash
# 1. 設定 GCP 專案與區域
export PROJECT_ID="openpassexam-576290"
export REGION="asia-east1"

# 2. 啟用必要 API
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com --project=$PROJECT_ID

# 3. 建立 Artifact Registry 存放區
gcloud artifacts repositories create passexam-repo \
    --repository-format=docker \
    --location=$REGION \
    --description="PassExam Web Container Repository" \
    --project=$PROJECT_ID

# 4. 透過 Cloud Build 建置並推送映像檔
gcloud builds submit --tag $REGION-docker.pkg.dev/$PROJECT_ID/passexam-repo/passexam-web:latest --project=$PROJECT_ID

# 5. 部署至 Cloud Run
gcloud run deploy passexam-web \
    --image $REGION-docker.pkg.dev/$PROJECT_ID/passexam-repo/passexam-web:latest \
    --platform managed \
    --region $REGION \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1 \
    --project=$PROJECT_ID
```

---

## 🛡️ 3. 維運與監控 (Operations & Monitoring)

- **日誌查看**：
  ```bash
  gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=passexam-web" --limit 50
  ```
- **流量配置**：
  Cloud Run 預設為最新修訂版本配置 100% 流量。若需進行藍綠部署或金絲雀發布，可在 Cloud Console 調整流量權重。
