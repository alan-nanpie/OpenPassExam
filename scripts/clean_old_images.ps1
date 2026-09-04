# ==============================================================================
# PassExam - Google Artifact Registry 歷史未標籤映像檔清理工具 (PowerShell)
#
# 功能：
# 1. 安全過濾：僅刪除無任何標籤 (Untagged) 的過期歷史建置映像檔。
# 2. 保留最新：絕對保留帶有標籤（如 latest 或自訂版號）的生產中映像檔。
# 3. 節省費用：定期釋放 Artifact Registry / Cloud Storage 的磁碟空間與配額。
# ==============================================================================

[CmdletBinding()]
param (
    [switch]$Force = $false
)

$ErrorActionPreference = "Continue"

function Write-Header {
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host " 🧹 OpenPassExam - Artifact Registry 映像檔清理管線" -ForegroundColor Yellow
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

# 1. 載入私有設定檔
$SCRIPT_DIR = $PSScriptRoot
if (-not $SCRIPT_DIR) {
    $SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if (-not $SCRIPT_DIR) {
    $SCRIPT_DIR = Join-Path (Get-Location) "scripts"
}
$ENV_FILE = Join-Path $SCRIPT_DIR "deploy.env"

$PROJECT_ID = "openpassexam-576290"
$REGION = "asia-east1"
$REPO_NAME = "openpassexam-repo"
$SERVICE_NAME = "openpassexam-web"

if (Test-Path $ENV_FILE) {
    Write-Step "1/3" "從設定檔 (scripts/deploy.env) 載入配置..."
    Get-Content $ENV_FILE | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
            $parts = $line.Split("=", 2)
            $key = $parts[0].Trim()
            $val = $parts[1].Trim()
            switch ($key) {
                "GCP_PROJECT_ID" { if ($val) { $PROJECT_ID = $val } }
                "GCP_REGION"     { if ($val) { $REGION = $val } }
                "REPO_NAME"      { if ($val) { $REPO_NAME = $val } }
                "SERVICE_NAME"   { if ($val) { $SERVICE_NAME = $val } }
            }
        }
    }
}

$IMAGE_BASE = "$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$SERVICE_NAME"
Write-Host "🎯 專案 ID       : $PROJECT_ID" -ForegroundColor Gray
Write-Host "🎯 存放庫路徑   : $IMAGE_BASE`n" -ForegroundColor Gray

# 2. 檢索所有映像檔並找出未標籤 (Untagged) 的歷史舊版本
Write-Step "2/3" "掃描 Artifact Registry 中的映像檔清單..."
$rawJson = gcloud artifacts docker images list $IMAGE_BASE --include-tags --format="json(package,version,tags)" --project=$PROJECT_ID 2>$null

if (-not $rawJson) {
    Write-Success "存放區內目前無任何映像檔，無需清理。"
    exit 0
}

$images = $rawJson | ConvertFrom-Json
$untaggedImages = @($images | Where-Object { -not $_.tags -or $_.tags.Count -eq 0 })
$taggedImages = @($images | Where-Object { $_.tags -and $_.tags.Count -gt 0 })

Write-Host "📊 映像檔統計總覽：" -ForegroundColor White
Write-Host "   • 正在使用/具備標籤之映像檔 (保護不刪除) : $($taggedImages.Count) 個" -ForegroundColor Green
foreach ($t in $taggedImages) {
    Write-Host "     - 標籤 [$($t.tags -join ', ')] -> $($t.version)" -ForegroundColor DarkGreen
}
Write-Host "   • 歷史無標籤 (Untagged) 待清理映像檔     : $($untaggedImages.Count) 個" -ForegroundColor Yellow

if ($untaggedImages.Count -eq 0) {
    Write-Success "太棒了！目前沒有任何無標籤的歷史舊映像檔需要清理。"
    exit 0
}

# 3. 執行清理作業
Write-Step "3/3" "準備清除 $($untaggedImages.Count) 個未標籤歷史映像檔..."
$deletedCount = 0

foreach ($img in $untaggedImages) {
    $targetUri = "$($img.package)@$($img.version)"
    Write-Host "🗑️ 正在刪除: $($img.version)... " -NoNewline -ForegroundColor Gray
    gcloud artifacts docker images delete $targetUri --delete-tags --quiet --project=$PROJECT_ID 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "已清除" -ForegroundColor Green
        $deletedCount++
    } else {
        Write-Host "略過或失敗" -ForegroundColor Red
    }
}

Write-Host "`n🎉 ========================================================" -ForegroundColor Green
Write-Success "清理完成！共成功刪除 $deletedCount 個過期無標籤映像檔。"
Write-Host "💡 保留最新生效版本：" -ForegroundColor Cyan
foreach ($t in $taggedImages) {
    Write-Host "   • 標籤 [$($t.tags -join ', ')] : $($t.version)" -ForegroundColor Yellow
}
Write-Host "========================================================`n" -ForegroundColor Green
