# ExpenseIQ

Smart personal finance tracking for Android — built with Flutter and Firebase.

**Live site:** [expenseiqapp.com](https://expenseiqapp.com)  
**Download:** [expenseiqapp.com/downloads/ExpenseIQ.apk](https://expenseiqapp.com/downloads/ExpenseIQ.apk)

## Overview

ExpenseIQ helps users track spending, manage budgets, scan receipts, and understand their finances across multiple currencies. The app includes biometric lock, Google Sign-In, in-app updates, and a responsive marketing website.

## Features

- Expense tracking with categories and budgets
- Multi-currency support with live exchange rates
- Receipt scanning and OCR text recognition
- Analytics, charts, and PDF/CSV report export
- Google Sign-In and email/password authentication
- Biometric app lock (fingerprint / Face ID)
- Push notifications
- In-app update checks
- Localization: English, Turkish, Arabic, French, Korean, and Russian (with RTL support for Arabic)
- Contact support form (stored in Firestore)

## Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile app | Flutter, Dart |
| Backend | Firebase Auth, Cloud Firestore, Firebase Analytics, Firebase Messaging |
| OCR | Google ML Kit |
| Website | Static HTML/CSS/JS |
| Hosting | Netlify |
| Android signing | Release keystore (`android/app/`) |

## Project Structure

```
expense_iq/
├── lib/                 # Flutter app source
│   ├── screens/         # UI screens
│   ├── services/      # Currency, OCR, reports, updates, translations
│   └── main.dart
├── android/             # Android native config and signing
├── ios/                 # iOS native config
├── website/             # Landing page, legal pages, APK download
├── firestore.rules      # Firestore security rules
├── firebase.json        # Firebase project config
└── netlify.toml         # Netlify deploy config (publishes website/)
```

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (SDK `>=3.4.0`)
- Android Studio / Android SDK
- JDK 17
- A Firebase project with Auth, Firestore, and Analytics enabled
- `google-services.json` in `android/app/` (not committed if using private config)

## Getting Started

```bash
# Clone the repo
git clone https://github.com/Carlm832/expenseiq.git
cd expenseiq

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

## Android Release Build

1. Copy `android/key.properties.example` to `android/key.properties` and fill in your keystore details.
2. Place your release keystore at `android/app/expenseiq-release.keystore` (or update `storeFile` in `key.properties`).
3. Register your **release SHA-1** fingerprint in the Firebase Console, then download an updated `google-services.json`.
4. Build:

```bash
flutter build apk --release --split-per-abi --target-platform android-arm64
```

The APK output is at:

```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Copy it to `website/downloads/ExpenseIQ.apk` and update `website/version.json` before deploying.

## Firebase Setup

1. Create a Firebase project and add an Android app with package name `com.expenseiq.expense_iq_flutter`.
2. Enable **Google Sign-In** and **Email/Password** authentication.
3. Add SHA-1 fingerprints for both **debug** and **release** keystores in Firebase Console.
4. Deploy Firestore rules:

```bash
firebase deploy --only firestore:rules
```

## Website Deployment

The site is deployed from the `website/` folder via Netlify (`netlify.toml`). Pushing to `main` triggers a deploy when Netlify is connected to this repository.

After a new APK build, make sure these are committed and deployed together:

- `website/downloads/ExpenseIQ.apk`
- `website/version.json`

## Support

- **Email:** support@expenseiqapp.com
- **Blog:** [expenseiqapp.com/blog.html](https://expenseiqapp.com/blog.html)

## License

This project is not licensed for public redistribution without permission from the authors.
