# 🔒 Security Fix - Exposed API Keys

## Issue
GitHub Secret Scanning detected exposed Google API Keys in Firebase configuration files:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

## Actions Taken

### 1. ✅ Added Files to .gitignore
Both Firebase configuration files have been added to `.gitignore` to prevent future commits.

### 2. ✅ Removed from Git Tracking
Files have been removed from git tracking (but kept locally for development).

### 3. ⚠️ IMPORTANT: Next Steps Required

#### A. Regenerate Firebase API Keys (CRITICAL)
Since the keys were publicly exposed on GitHub, you **MUST** regenerate them:

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `book-swap-92678`
3. **Navigate to Project Settings** (gear icon) → **General**
4. **For Android:**
   - Scroll to "Your apps" section
   - Find the Android app
   - Click on `google-services.json` download button
   - Replace your local `android/app/google-services.json` with the new file

5. **For iOS:**
   - In the same "Your apps" section
   - Find the iOS app
   - Click on `GoogleService-Info.plist` download button
   - Replace your local `ios/Runner/GoogleService-Info.plist` with the new file

6. **Optional - Restrict API Keys:**
   - Go to **Google Cloud Console**: https://console.cloud.google.com/
   - Navigate to **APIs & Services** → **Credentials**
   - Find the API keys listed in the alerts:
     - `AIzaSyBPreuQUw9iI5hnIRJ3NdnyEO9TjXoKjcQ` (Android)
     - `AIzaSyB98KZXPjW_eeBnm8sflzKzMQtHcn_dXik` (iOS)
   - Either **delete them** and use new ones, or **restrict them** by:
     - Application restrictions (Android apps, iOS apps)
     - API restrictions (only allow required Firebase APIs)

#### B. Remove Files from Git History (CRITICAL)
The files still exist in your git history. To completely remove them:

**Option 1: Using BFG Repo-Cleaner (Recommended)**
```bash
# Download BFG from https://rtyley.github.io/bfg-repo-cleaner/
# Then run:
java -jar bfg.jar --delete-files google-services.json
java -jar bfg.jar --delete-files GoogleService-Info.plist
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

**Option 2: Using git filter-repo**
```bash
# Install git-filter-repo first
pip install git-filter-repo

# Remove the files from history
git filter-repo --path android/app/google-services.json --invert-paths
git filter-repo --path ios/Runner/GoogleService-Info.plist --invert-paths
git push --force
```

**⚠️ WARNING:** Both options rewrite git history. Coordinate with your team before force pushing!

#### C. Commit the Security Fix
```bash
git add .gitignore
git commit -m "chore: add Firebase config files to .gitignore for security"
git push
```

#### D. Close GitHub Security Alerts
After regenerating keys and removing from history:
1. Go to your GitHub repository
2. Navigate to **Security** → **Secret scanning**
3. Mark the alerts as "Revoked" or "Won't fix" (if you've regenerated keys)

## Best Practices Going Forward

1. **Never commit sensitive files**: Always check `.gitignore` before initial commit
2. **Use environment variables**: For additional secrets, use environment variables
3. **Enable Secret Scanning**: Keep GitHub secret scanning enabled (already done)
4. **Regular Audits**: Periodically review what's being committed
5. **Team Training**: Ensure all team members understand security practices

## Development Setup for New Team Members

When setting up the project, developers should:

1. Clone the repository
2. Download `google-services.json` and `GoogleService-Info.plist` from Firebase Console
3. Place them in the correct directories:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. These files will be ignored by git and not committed

## Additional Resources

- [Firebase Security Best Practices](https://firebase.google.com/support/privacy)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [Removing Sensitive Data from Git](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
