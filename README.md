# LexiLens

LexiLens is a Flutter vocabulary learning app that uses Firebase for authentication and storage, Gemini for AI vocabulary help, and on-device object detection to discover words from the camera.

## Prerequisites

Install the following before running the project:

- Flutter SDK with Dart `3.8.1` or newer
- Android Studio or Xcode, depending on the device you want to run
- A Firebase project
- A Gemini API key

Check your local Flutter setup:

```sh
flutter doctor
```

Resolve any required Android, iOS, or web setup warnings before continuing.

## Step-by-Step Setup

1. Open the project folder.

```sh
cd /path/to/LexiLens/project
```

2. Install Flutter dependencies.

```sh
flutter pub get
```

3. Create your local environment file.

```sh
cp .env.example .env
```

4. Fill in `.env` with your Firebase and Gemini values.

Required values:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project-id.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com

FIREBASE_ANDROID_API_KEY=your-android-api-key
FIREBASE_ANDROID_APP_ID=your-android-app-id

FIREBASE_IOS_API_KEY=your-ios-api-key
FIREBASE_IOS_APP_ID=your-ios-app-id
FIREBASE_IOS_BUNDLE_ID=com.lexilens.lexilens

FIREBASE_WEB_API_KEY=your-web-api-key
FIREBASE_WEB_APP_ID=your-web-app-id

GEMINI_API_KEY=your-gemini-api-key
```

The app loads `.env` at startup. If this file is missing or contains placeholder values, the app will show a Firebase initialization error.

5. Configure Firebase.

In the Firebase console:

- Enable Authentication.
- Enable the Email/Password provider.
- Enable the Google provider if you want Google sign-in to work.
- Create a Cloud Firestore database.
- Create Firebase Storage if you plan to use storage-backed features.

For platform apps:

- Android package name: `com.lexilens.lexilens`
- iOS bundle ID: use the same value as `FIREBASE_IOS_BUNDLE_ID`

This repo already contains Firebase platform config files:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Replace those files if you connect the app to a different Firebase project.

6. Deploy Firestore rules if you are using Firebase CLI.

```sh
firebase deploy --only firestore:rules,firestore:indexes
```

7. Confirm a device or emulator is available.

```sh
flutter devices
```

8. Run the app.

For the default available device:

```sh
flutter run
```

For a specific target:

```sh
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

For camera-based object detection, use a physical Android or iOS device when possible. Emulators and web builds may not expose a working camera or may behave differently with the TensorFlow Lite plugin.

## Running Tests

Run the test suite:

```sh
flutter test
```

Run static analysis:

```sh
flutter analyze
```

Format Dart files:

```sh
dart format .
```

## Useful Project Files

- `lib/main.dart`: app startup, `.env` loading, and Firebase initialization
- `lib/firebase_options.dart`: Firebase options loaded from `.env`
- `.env.example`: required environment variable template
- `firebase.json`: Firebase project config for Firestore rules and indexes
- `firestore.rules`: Firestore security rules
- `pubspec.yaml`: Flutter dependencies and bundled assets
- `assets/detect.tflite`: object detection model
- `assets/labelmap.txt`: model labels

## Troubleshooting

If the app opens to a Firebase initialization error, check that `.env` exists, all required values are filled in, and the Firebase app IDs match the platform you are running.

If Google sign-in fails, confirm the Google provider is enabled in Firebase Authentication and that the Android package name or iOS bundle ID matches the app registered in Firebase.

If camera detection does not start, try a physical device and confirm camera permission is granted.

If the model fails to load, confirm `assets/detect.tflite` and `assets/labelmap.txt` exist and that `flutter pub get` has completed successfully.
