# ==============================================================================
# PassExam - 根目錄一鍵發布快捷入口 (Root Deploy Shortcut)
#
# 執行此程式將自動調用 scripts/deploy_cloud_run.ps1
# ==============================================================================

$SCRIPT_PATH = Join-Path $PSScriptRoot "scripts\deploy_cloud_run.ps1"

if (Test-Path $SCRIPT_PATH) {
    & $SCRIPT_PATH
} else {
    Write-Error "找不到發布核心腳本：$SCRIPT_PATH"
}
