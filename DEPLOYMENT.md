# EchoSphere Deployment Guide

## Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio/Xcode (for mobile builds)
- Web server (for web deployment)
- Infura account (for blockchain access)
- OpenAI API key

## Environment Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/echosphere.git
   cd echosphere
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

## Configuration
Update `lib/constants.dart` with:
- Infura project ID and URL
- Smart contract addresses
- OpenAI API key
- Sentiment analysis endpoint
- AR content storage URLs

## Building the App

### Android
1. Update package name in:
   - `android/app/build.gradle`
   - `android/app/src/main/AndroidManifest.xml`

2. Build release APK:
   ```bash
   flutter build apk --release
   ```

3. Or build app bundle:
   ```bash
   flutter build appbundle
   ```

### iOS
1. Update bundle identifier in:
   - `ios/Runner.xcodeproj/project.pbxproj`
   - `ios/Runner/Info.plist`

2. Build for release:
   ```bash
   flutter build ios --release
   ```

3. Open Xcode and archive:
   ```bash
   open ios/Runner.xcworkspace
   ```

### Web
1. Build for production:
   ```bash
   flutter build web --release
   ```

2. Deploy contents of `build/web` to your hosting provider

## Continuous Integration
Sample GitHub Actions workflow (`.github/workflows/deploy.yml`):
```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

## Post-Deployment
1. Set up monitoring:
   - Firebase Crashlytics
   - Sentry error tracking
   - Blockchain transaction monitoring

2. Configure analytics:
   - Google Analytics for usage metrics
   - Custom dashboard for engagement metrics
