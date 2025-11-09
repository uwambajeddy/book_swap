# 🔥 Firebase Configuration Setup

## For New Developers / Team Members

The Firebase configuration files (`google-services.json` and `GoogleService-Info.plist`) are **not included in this repository** for security reasons. You need to download them from Firebase Console.

### Step 1: Access Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Sign in with your Google account (make sure you have access to the project)
3. Select the project: **book-swap-92678**

### Step 2: Download Android Configuration

1. In Firebase Console, click the **gear icon** (⚙️) → **Project settings**
2. Scroll down to **Your apps** section
3. Find the **Android app** (package: `com.example.book_swap`)
4. Click the **google-services.json** download button
5. Save the file to: `android/app/google-services.json`

### Step 3: Download iOS Configuration

1. In the same **Your apps** section
2. Find the **iOS app** (bundle ID: `com.example.bookSwap`)
3. Click the **GoogleService-Info.plist** download button
4. Save the file to: `ios/Runner/GoogleService-Info.plist`

### Step 4: Verify Files Are Ignored

These files should **NOT** appear in `git status`. They are listed in `.gitignore`:

```bash
# Check that files are ignored
git status

# You should NOT see:
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist
```

### Step 5: Run the App

After placing the files, you can run the app normally:

```bash
flutter pub get
flutter run
```

## File Locations Summary

```
book_swap/
├── android/
│   └── app/
│       └── google-services.json       ← Download from Firebase (Android)
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist   ← Download from Firebase (iOS)
```

## Important Notes

- ⚠️ **Never commit these files to git**
- ⚠️ **Never share these files publicly**
- ⚠️ **Don't include them in screenshots or screen recordings**
- ✅ Each developer needs to download their own copy
- ✅ Files are automatically ignored by `.gitignore`

## Troubleshooting

### "MissingPluginException" or Firebase not working

**Solution:** Make sure you've downloaded and placed both configuration files correctly.

### "File not found: google-services.json"

**Solution:** Download the file from Firebase Console and place it in `android/app/`

### "File not found: GoogleService-Info.plist"

**Solution:** Download the file from Firebase Console and place it in `ios/Runner/`

### Still having issues?

Contact the project maintainer for Firebase Console access.

## Need Access to Firebase Project?

If you don't have access to the Firebase project, contact:
- **Project Owner:** [Your Name/Email]
- **Firebase Project ID:** book-swap-92678
