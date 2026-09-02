# CI/CD 自動化建置 (CI/CD Automation)

> **AI Agent Target:** Pipeline definitions for Google Cloud Build, testing gates, and automated deployment.
> **Human Target:** CI/CD 自動化流程說明，包含代碼分析、測試執行與自動發布。

## Google Cloud Build 管線 (`cloudbuild.yaml`)
```yaml
steps:
  # 1. 執行靜態代碼分析
  - name: 'ghcr.io/cirruslabs/flutter:3.27.0'
    entrypoint: 'flutter'
    args: ['analyze', 'lib']

  # 2. 執行單元與 Widget 測試
  - name: 'ghcr.io/cirruslabs/flutter:3.27.0'
    entrypoint: 'flutter'
    args: ['test', '--coverage']

  # 3. 建置 Android AAB
  - name: 'ghcr.io/cirruslabs/flutter:3.27.0'
    entrypoint: 'flutter'
    args: ['build', 'appbundle', '--release']

  # 4. 部署至 Firebase Hosting
  - name: 'gcr.io/$PROJECT_ID/firebase'
    args: ['deploy', '--only', 'hosting']
```
