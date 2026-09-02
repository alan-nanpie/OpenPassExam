# Web Deployment Guide

> **AI Agent Target:** Hosting configuration, CanvasKit optimization, and Firebase Hosting deployment.
> **Human Target:** Guide to deploying PassExam Web to Firebase Hosting and Google Cloud Run.

## 1. Firebase Hosting Deployment

```bash
# 1. Build Web release
flutter build web --release --web-renderer canvaskit

# 2. Deploy to Firebase Hosting
firebase deploy --only hosting
```

## 2. `firebase.json` Configuration
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
    ]
  }
}
```
