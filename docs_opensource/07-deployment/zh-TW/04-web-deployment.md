# Web 部署指南 (Web Deployment)

> **AI Agent Target:** Hosting configuration, CanvasKit optimization, and Firebase Hosting deployment.
> **Human Target:** 將 PassExam Web 端部署至 Firebase Hosting 與 Google Cloud Run 的指南。

## 1. Firebase Hosting 部署流程

```bash
# 1. 建置 Web 版本
flutter build web --release --web-renderer canvaskit

# 2. 部署至 Firebase Hosting
firebase deploy --only hosting
```

## 2. `firebase.json` 配置
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css|wasm)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

## 3. Google Cloud Run 容器化部署流程

PassExam 支援透過 Docker 多階段建置封裝為輕量 Nginx 容器，並部署至 Google Cloud Run。

### 3.1 一鍵自動化部署 (PowerShell)
```powershell
./scripts/deploy_cloud_run.ps1
```

### 3.2 手動建置與發布步驟
```bash
# 1. 啟用必要 API
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com

# 2. 建立 Artifact Registry (若尚未建立)
gcloud artifacts repositories create passexam-repo \
    --repository-format=docker \
    --location=asia-east1 \
    --description="PassExam Web Container Repository"

# 3. 透過 Cloud Build 建置映像檔並推送
gcloud builds submit --tag asia-east1-docker.pkg.dev/YOUR_PROJECT_ID/passexam-repo/passexam-web:latest

# 4. 部署至 Cloud Run
gcloud run deploy passexam-web \
    --image asia-east1-docker.pkg.dev/YOUR_PROJECT_ID/passexam-repo/passexam-web:latest \
    --platform managed \
    --region asia-east1 \
    --allow-unauthenticated \
    --port 8080 \
    --memory 512Mi \
    --cpu 1
```

