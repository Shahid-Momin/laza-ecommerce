# Firebase Setup Guide

This project uses Firebase Authentication and Cloud Firestore.
**No private credentials are committed to this repository.**

Follow these steps to set up your own Firebase project.

---

## Step 1 — Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project**
3. Name it (e.g., `laza-ecommerce`)
4. Disable/Enable Google Analytics — either works
5. Click **Create project**

---

## Step 2 — Register Your Android App

1. In the Firebase Console, click the **Android** icon on the project overview
2. **Android package name** — must match `android/app/build.gradle.kts`:
   ```
   com.example.laza
   ```
3. Click **Register app**
4. **Download `google-services.json`**
5. Place it at: `android/app/google-services.json`

> ⚠️ This file is **NOT** committed to the repo. Each developer must download
> their own copy from their Firebase Console.

---

## Step 3 — Enable Authentication

1. Firebase Console → **Authentication** → **Get started**
2. Under **Sign-in method**, enable:
    - **Email/Password** — toggle ON, click Save
    - **Google** — toggle ON, set a project support email, click Save

---

## Step 4 — Register Your Debug SHA-1 (for Google Sign-In)

### Get the SHA-1

**Windows (PowerShell):**
```powershell
cd android
.\gradlew.bat signingReport
```

**macOS / Linux:**
```bash
cd android
./gradlew signingReport
```

Look for **`Variant: debug`** and copy the **SHA1** value.

### Add to Firebase

1. Firebase Console → **Project settings** → **Your apps** → Android app
2. Click **Add fingerprint**
3. Paste the SHA-1
4. Click **Save**
5. **Download the updated `google-services.json`** and replace the one in
   `android/app/`

---

## Step 5 — Create Firestore Database

1. Firebase Console → **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location closest to you
5. Click **Enable**

### Deploy Security Rules

1. In Firestore, go to the **Rules** tab
2. Replace the contents with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;

      match /wishlist/{pid} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /cart/{pid} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
      match /orders/{oid} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }

    match /products/{productId}/reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null
                            && request.auth.uid == resource.data.uid;
    }
  }
}
```

3. Click **Publish**

---

## Step 6 — Verify `firebase_options.dart`

Open `lib/firebase_options.dart`. It contains the public Firebase config
(API key, app ID, project ID, etc.).

- The values are **public-safe** — Firebase uses SHA-1 signing, not the API
  key, to authenticate your app
- But you can regenerate this file for your own project if you want

To regenerate:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Select your Firebase project → the CLI updates `firebase_options.dart`
automatically.

---

## Step 7 — Run the App

```bash
flutter clean
flutter pub get
flutter run
```

Expected:
- Splash → Onboarding appears
- Tap Men/Women → Get Started
- Create account → Interests → Home

---

## 🗂 Firestore Data Structure

```
users/{uid}
  ├── name, email, phone, gender, dateOfBirth
  ├── profileImage (local file path)
  ├── favoriteCategories[]
  ├── createdAt, updatedAt
  ├── wishlist/{productId}
  ├── cart/{productId}
  └── orders/{orderId}

products/{productId}/reviews/{reviewId}
```

---

## 🔒 Security Notes

**Never commit these files:**
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `android/key.properties`
- Any `.env` files

**Already git-ignored** in this project's `.gitignore`.

If you accidentally committed them:

```bash
git rm --cached android/app/google-services.json
git commit -m "chore: remove credentials from tracking"
git push
```

The simplest fix is to delete the GitHub repo and re-push from scratch with
the corrected `.gitignore`.

---

## ❓ Troubleshooting

| Issue | Fix |
|-------|-----|
| `ApiException: 10` on Google Sign-In | SHA-1 not registered in Firebase, or `google-services.json` not updated |
| `FirebaseException: no-app` | `google-services.json` missing or in wrong folder (must be in `android/app/`) |
| Email reset link doesn't arrive | Check spam; verify sender email in Firebase Authentication Templates |
| Firestore permission denied | Rules not published, or user not authenticated |

---

**That's it.** Firebase is now configured for your local build.