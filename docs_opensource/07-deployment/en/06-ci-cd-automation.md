# CI/CD Automation

> **AI Agent Target:** Pipeline definitions for Google Cloud Build, testing gates, and automated deployment.
> **Human Target:** CI/CD automation workflow covering analysis, testing, and deployment.

## Google Cloud Build Pipeline (`cloudbuild.yaml`)
```yaml
steps:
  - name: 'ghcr.io/cirruslabs/flutter:3.27.0'
    entrypoint: 'flutter'
    args: ['analyze', 'lib']

  - name: 'ghcr.io/cirruslabs/flutter:3.27.0'
    entrypoint: 'flutter'
    args: ['test', '--coverage']

  - name: 'ghcr.io/cirruslabs/flutter:3.27.0'
    entrypoint: 'flutter'
    args: ['build', 'appbundle', '--release']

  - name: 'gcr.io/$PROJECT_ID/firebase'
    args: ['deploy', '--only', 'hosting']
```
