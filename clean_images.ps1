# ==============================================================================
# PassExam - 根目錄清理 Artifact Registry 舊映像檔快捷入口 (Clean Images Shortcut)
#
# 執行此程式將自動調用 scripts/clean_old_images.ps1
# ==============================================================================

$SCRIPT_PATH = Join-Path $PSScriptRoot "scripts\clean_old_images.ps1"

if (Test-Path $SCRIPT_PATH) {
    if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
        & pwsh -ExecutionPolicy Bypass -File $SCRIPT_PATH @args
    } else {
        & powershell -ExecutionPolicy Bypass -File $SCRIPT_PATH @args
    }
} else {
    Write-Error "找不到清理核心腳本：$SCRIPT_PATH"
}
