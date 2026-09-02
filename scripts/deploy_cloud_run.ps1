# ==============================================================================
# PassExam - Google Cloud Run 一鍵部署腳本 (PowerShell)
# ==============================================================================

$ErrorActionPreference = "Stop"

$REGION = "asia-east1"
$REPO_NAME = "passexam-repo"
$SERVICE_NAME = "passexam-web"
$IMAGE_TAG = "latest"

Write-Host "🔍 檢查當前 GCP 專案..." -ForegroundColor Cyan
$PROJECT_ID = (gcloud config get-value project 2>$null).Trim()

if (-not $PROJECT_ID) {
    Write-Error "❌ 未設定 GCP 專案，請先執行: gcloud config set project <PROJECT_ID>"
    exit 1
}

Write-Host "✅ 目標 GCP 專案: $PROJECT_ID" -ForegroundColor Green
Write-Host "✅ 目標部署區域: $REGION" -ForegroundColor Green

# 1. 啟用必要的 Google Cloud APIs
Write-Host "`n🚀 [1/4] 檢查並啟用 GCP APIs..." -ForegroundColor Cyan
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com --project=$PROJECT_ID

# 2. 檢查或建立 Artifact Registry
Write-Host "`n📦 [2/4] 檢查 Artifact Registry 存放區..." -ForegroundColor Cyan
$repoExists = gcloud artifacts repositories describe $REPO_NAME --location=$REGION --project=$PROJECT_ID 2>$null
if (-not $repoExists) {
    Write-Host "建立 Artifact Registry 存放區: $REPO_NAME..." -ForegroundColor Yellow
    gcloud artifacts repositories create $REPO_NAME `
        --repository-format=docker `
        --location=$REGION `
        --description="PassExam Web Container Repository" `
        --project=$PROJECT_ID
} else {
    Write-Host "Artifact Registry 存放區 $REPO_NAME 已存在。" -ForegroundColor Green
}

# 3. 雲端建置並推送映像檔
$IMAGE_URI = "$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/${SERVICE_NAME}:$IMAGE_TAG"
Write-Host "`n🔨 [3/4] 透過 Cloud Build 建置容器映像檔..." -ForegroundColor Cyan
Write-Host "Image URI: $IMAGE_URI" -ForegroundColor Gray
gcloud builds submit --tag $IMAGE_URI --project=$PROJECT_ID

# 4. 部署至 Google Cloud Run
Write-Host "`n🌐 [4/4] 部署服務至 Google Cloud Run..." -ForegroundColor Cyan
gcloud run deploy $SERVICE_NAME `
    --image $IMAGE_URI `
    --platform managed `
    --region $REGION `
    --allow-unauthenticated `
    --port 8080 `
    --memory 512Mi `
    --cpu 1 `
    --project=$PROJECT_ID

Write-Host "`n🎉 ========================================================" -ForegroundColor Green
Write-Host "✨ 恭喜！PassExam Web 版已成功部署至 Google Cloud Run！" -ForegroundColor Green
$SERVICE_URL = (gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --project=$PROJECT_ID --format 'value(status.url)' 2>$null).Trim()
Write-Host "🔗 服務公開網址: $SERVICE_URL" -ForegroundColor Yellow
Write-Host "========================================================`n" -ForegroundColor Green
