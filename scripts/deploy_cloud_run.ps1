# ==============================================================================
# PassExam - Google Cloud Run 全自動安全發布工具 (PowerShell)
# 
# 特點：
# 1. 【100% 零機密外洩】：絕不寫死專案 ID，機密配置獨立存放於被 gitignore 排除的 deploy.env。
# 2. 【新手零基礎防呆】：自動偵測環境、自動引導建立設定、本機無需安裝 Docker/Flutter。
# 3. 【一鍵發布】：自動啟用 APIs、建立映像庫、雲端構建與部署。
# ==============================================================================

$ErrorActionPreference = "Continue"

function Write-Header {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host " 🚀 OpenPassExam - Google Cloud Run 自動化發布管線" -ForegroundColor Yellow
    Write-Host "========================================================`n" -ForegroundColor Cyan
}

function Write-Step([string]$step, [string]$msg) {
    Write-Host "[$step] $msg" -ForegroundColor Cyan
}

function Write-Success([string]$msg) {
    Write-Host "✅ $msg" -ForegroundColor Green
}

function Write-Warn([string]$msg) {
    Write-Host "⚠️ $msg" -ForegroundColor Yellow
}

function Write-Err([string]$msg) {
    Write-Host "❌ $msg" -ForegroundColor Red
}

Write-Header

# 0. 基礎工具檢查 (Check gcloud CLI)
if (-not (Get-Command "gcloud" -ErrorAction SilentlyContinue)) {
    Write-Err "未偵測到 Google Cloud CLI (gcloud)！"
    Write-Host "`n👉 請先前往 Google 官方下載並安裝 Google Cloud SDK：" -ForegroundColor Yellow
    Write-Host "   https://cloud.google.com/sdk/docs/install`n" -ForegroundColor White
    exit 1
}

# 1. 載入或引導建立私有機密設定檔 (scripts/deploy.env)
$SCRIPT_DIR = $PSScriptRoot
if (-not $SCRIPT_DIR) {
    $SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $SCRIPT_DIR) {
    $SCRIPT_DIR = Join-Path (Get-Location) "scripts"
}
$ENV_FILE = Join-Path $SCRIPT_DIR "deploy.env"
$ENV_EXAMPLE_FILE = Join-Path $SCRIPT_DIR "deploy.env.example"

$PROJECT_ID = ""
$REGION = "asia-east1"
$REPO_NAME = "openpassexam-repo"
$SERVICE_NAME = "openpassexam-web"
$IMAGE_TAG = "latest"
$MEMORY_LIMIT = "512Mi"
$CPU_LIMIT = "1"

if (Test-Path $ENV_FILE) {
    Write-Step "1/5" "從私有設定檔 (scripts/deploy.env) 載入配置..."
    Get-Content $ENV_FILE | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $parts = $line.Split("=", 2)
            $key = $parts[0].Trim()
            $val = $parts[1].Trim()
            switch ($key) {
                "GCP_PROJECT_ID" { $PROJECT_ID = $val }
                "GCP_REGION"     { if ($val) { $REGION = $val } }
                "REPO_NAME"      { if ($val) { $REPO_NAME = $val } }
                "SERVICE_NAME"   { if ($val) { $SERVICE_NAME = $val } }
                "IMAGE_TAG"      { if ($val) { $IMAGE_TAG = $val } }
                "MEMORY_LIMIT"   { if ($val) { $MEMORY_LIMIT = $val } }
                "CPU_LIMIT"      { if ($val) { $CPU_LIMIT = $val } }
            }
        }
    }
} else {
    Write-Warn "未找到私有設定檔 (scripts/deploy.env)。"
}

# 若無設定檔或 PROJECT_ID 為空，嘗試讀取 gcloud 當前專案或提示使用者輸入
if (-not $PROJECT_ID -or $PROJECT_ID -eq "your-gcp-project-id") {
    $activeGcpProject = (gcloud config get-value project 2>$null).Trim()
    if ($activeGcpProject -and $activeGcpProject -ne "(unset)") {
        $PROJECT_ID = $activeGcpProject
        Write-Host "💡 自動偵測到 gcloud 當前作用專案：$PROJECT_ID" -ForegroundColor Gray
    } else {
        Write-Host "`n請輸入您在 Google Cloud 建立的專案 ID (Project ID)：" -ForegroundColor Yellow
        $inputProject = Read-Host "GCP Project ID"
        $PROJECT_ID = $inputProject.Trim()
    }
}

if (-not $PROJECT_ID) {
    Write-Err "專案 ID 不能為空！請確認後重新執行。"
    exit 1
}

# 自動為使用者儲存至 deploy.env，下次免手動輸入
if (-not (Test-Path $ENV_FILE)) {
    $saveChoice = Read-Host "`n是否將專案 ID ($PROJECT_ID) 儲存至本地 scripts/deploy.env？(Y/n)"
    if ($saveChoice -ne "n" -and $saveChoice -ne "N") {
        @"
# 本地專屬私有設定檔（已由 .gitignore 排除，絕不上傳 GitHub）
GCP_PROJECT_ID=$PROJECT_ID
GCP_REGION=$REGION
REPO_NAME=$REPO_NAME
SERVICE_NAME=$SERVICE_NAME
IMAGE_TAG=$IMAGE_TAG
MEMORY_LIMIT=$MEMORY_LIMIT
CPU_LIMIT=$CPU_LIMIT
"@ | Out-File -FilePath $ENV_FILE -Encoding utf8
        Write-Success "已為您建立 scripts/deploy.env！(此檔案已受保護，絕不上傳 GitHub)"
    }
}

# 確保當前 CLI 作用專案與環境變數對齊
$env:CLOUDSDK_CORE_PROJECT = $PROJECT_ID
gcloud config set project $PROJECT_ID --quiet | Out-Null

Write-Host "`n🎯 部署配置清單：" -ForegroundColor Cyan
Write-Host "   • Google Cloud 專案 ID : $PROJECT_ID" -ForegroundColor White
Write-Host "   • 部署區域 (Region)   : $REGION" -ForegroundColor White
Write-Host "   • 服務名稱 (Service)  : $SERVICE_NAME" -ForegroundColor White
Write-Host "   • 容器庫 (Repository) : $REPO_NAME" -ForegroundColor White
Write-Host "   • 記憶體限制 (Memory) : $MEMORY_LIMIT" -ForegroundColor White
Write-Host "   • CPU 限制 (CPU)      : $CPU_LIMIT`n" -ForegroundColor White

# 2. 檢查並啟用必要 APIs
Write-Step "2/5" "檢查並啟用 Google Cloud 必備服務 API (Cloud Run, Artifact Registry, Cloud Build)..."
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com --project=$PROJECT_ID
Write-Success "Google Cloud APIs 已就緒。"

# 3. 檢查或建立 Artifact Registry
Write-Step "3/5" "檢查 Artifact Registry 容器存放區 [$REPO_NAME]..."
$existingRepos = (gcloud artifacts repositories list --location=$REGION --project=$PROJECT_ID --format="value(name)" 2>$null)
if (-not ($existingRepos -match $REPO_NAME)) {
    Write-Host "建立 Artifact Registry 存放區: $REPO_NAME ($REGION)..." -ForegroundColor Yellow
    gcloud artifacts repositories create $REPO_NAME `
        --repository-format=docker `
        --location=$REGION `
        --description="PassExam Web Container Repository" `
        --project=$PROJECT_ID
    Write-Success "Artifact Registry 建立完成。"
} else {
    Write-Success "Artifact Registry 存放區已存在。"
}

# 4. 透過 Cloud Build 雲端建置並推送映像檔
$IMAGE_URI = "$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/${SERVICE_NAME}:$IMAGE_TAG"
Write-Step "4/5" "透過 Google Cloud Build 在雲端建置 Flutter Web 容器映像檔..."
Write-Host "目標映像檔 URI: $IMAGE_URI" -ForegroundColor Gray
gcloud builds submit --tag $IMAGE_URI --project=$PROJECT_ID
if ($LASTEXITCODE -ne 0) {
    Write-Err "Cloud Build 建置失敗！請檢查日誌。"
    exit $LASTEXITCODE
}
Write-Success "容器映像檔建置並推送完成！"

# 5. 部署服務至 Google Cloud Run
Write-Step "5/5" "部署服務至 Google Cloud Run (全自動無伺服器託管)..."
gcloud run deploy $SERVICE_NAME `
    --image $IMAGE_URI `
    --platform managed `
    --region $REGION `
    --allow-unauthenticated `
    --port 8080 `
    --memory $MEMORY_LIMIT `
    --cpu $CPU_LIMIT `
    --project=$PROJECT_ID
if ($LASTEXITCODE -ne 0) {
    Write-Err "Cloud Run 部署失敗！"
    exit $LASTEXITCODE
}

# 6. 自動清理歷史未標籤映像檔 (保持儲存庫乾淨並節省費用)
$CLEAN_SCRIPT = Join-Path $SCRIPT_DIR "clean_old_images.ps1"
if (Test-Path $CLEAN_SCRIPT) {
    Write-Step "6/6" "自動清理 Artifact Registry 中過期的未標籤 (Untagged) 歷史映像檔..."
    & $CLEAN_SCRIPT
}

# 7. 取得並輸出線上正式網址
$SERVICE_URL = (gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --project=$PROJECT_ID --format="value(status.url)" 2>$null).Trim()

Write-Host "`n🎉 ========================================================" -ForegroundColor Green
Write-Host "✨ 恭喜！PassExam Web 版已成功部署至 Google Cloud Run！" -ForegroundColor Green
Write-Host "🌐 正式服務網址 (URL):" -ForegroundColor Cyan
Write-Host "   $SERVICE_URL" -ForegroundColor Yellow
Write-Host "========================================================`n" -ForegroundColor Green
Write-Host "💡 提示：此網址任何人透過手機或電腦瀏覽器皆可直接開啟使用！" -ForegroundColor Gray

