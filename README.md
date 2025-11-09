# BookSwap - Student Textbook Exchange Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.9.0-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A comprehensive mobile application that enables students to swap textbooks with each other, built with Flutter and Firebase.

## Features

✅ **User Authentication** - Email/password authentication with email verification  
✅ **Book Listings** - Full CRUD operations for textbook listings  
✅ **Swap System** - Request, accept, or reject book swap offers  
✅ **Real-time Chat** - Communication between users after swap initiation  
✅ **State Management** - Implemented using Provider pattern  
✅ **Image Upload** - Firebase Storage integration for book covers  
✅ **Clean Architecture** - Separation of concerns (Data, Domain, Presentation)

## Architecture

```
lib/
├── core/
│   ├── constants/          # App colors, strings, themes
│   └── utils/              # Helper functions
├── data/
│   ├── models/             # Data models (User, Book, Swap, Chat, Message)
│   └── services/           # Firebase services (Auth, Firestore, Storage)
├── domain/
│   └── providers/          # State management with Provider
└── presentation/
    ├── screens/            # UI screens organized by feature
    │   ├── auth/          # Authentication screens
    │   ├── browse/        # Browse listings
    │   ├── listings/      # My listings & post book
    │   ├── chats/         # Chat functionality
    │   └── settings/      # User settings
    └── widgets/           # Reusable UI components
```

### Database Schema

#### Users Collection
```
users/
  ├── {userId}/
      ├── id: string
      ├── email: string
      ├── fullName: string
      ├── emailVerified: boolean
      ├── createdAt: timestamp
      ├── notificationEnabled: boolean
      └── emailUpdatesEnabled: boolean
```

#### Books Collection
```
books/
  ├── {bookId}/
      ├── id: string
      ├── ownerId: string
      ├── ownerName: string
      ├── title: string
      ├── author: string
      ├── swapFor: string
      ├── condition: string (New, Like New, Good, Used)
      ├── status: string (Available, Pending, Swapped)
      ├── imageUrl: string
      ├── createdAt: timestamp
      └── updatedAt: timestamp
```

#### Swaps Collection
```
swaps/
  ├── {swapId}/
      ├── id: string
      ├── requesterId: string
      ├── requesterName: string
      ├── ownerId: string
      ├── ownerName: string
      ├── bookId: string
      ├── bookTitle: string
      ├── bookAuthor: string
      ├── bookImageUrl: string
      ├── status: string (Pending, Accepted, Rejected)
      ├── createdAt: timestamp
      └── updatedAt: timestamp
```

#### Chats Collection
```
chats/
  ├── {chatId}/
      ├── id: string
      ├── participantIds: array
      ├── participantNames: map
      ├── lastMessage: string
      ├── lastMessageTime: timestamp
      ├── lastMessageSenderId: string
      ├── unreadCount: map
      ├── createdAt: timestamp
      └── messages/
          ├── {messageId}/
              ├── id: string
              ├── chatId: string
              ├── senderId: string
              ├── senderName: string
              ├── text: string
              ├── timestamp: timestamp
              └── isRead: boolean
```

## Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `book-swap`
4. Disable Google Analytics (optional)
5. Click "Create Project"

### Step 2: Register Your App

#### For Android:
1. Click Android icon in Project Overview
2. Enter package name: `com.example.book_swap`
3. Download `google-services.json`
4. Place it in `android/app/`
5. Follow the setup instructions

#### For iOS (if needed):
1. Click iOS icon
2. Enter bundle ID: `com.example.bookSwap`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`
5. Follow the setup instructions

### Step 3: Enable Firebase Services

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
   - Save

2. **Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Choose "Start in test mode" (change rules later)
   - Select location closest to your users
   - Click "Enable"

3. **Firebase Storage**
   - Go to Storage
   - Click "Get started"
   - Start in test mode
   - Select location
   - Click "Done"

### Step 4: Security Rules

#### Firestore Rules (Production):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.ownerId;
    }
    
    match /swaps/{swapId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.requesterId || 
         request.auth.uid == resource.data.ownerId);
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.ownerId;
      allow delete: if request.auth.uid == resource.data.requesterId;
    }
    
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
      
      match /messages/{messageId} {
        allow read, create: if request.auth != null;
      }
    }
  }
}
```

#### Storage Rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.resource.size < 5 * 1024 * 1024 &&
        request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Installation & Setup

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase CLI (optional)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/uwambajeddy/book_swap.git
   cd book_swap
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Follow Firebase Setup steps above
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/` (if using iOS)

4. **Run the app**
   ```bash
   flutter run
   ```

## State Management - Provider Pattern

This app uses the **Provider** package for state management. Here's how it's implemented:

### Provider Structure

1. **AuthProvider** - Manages user authentication state
   - Sign up, sign in, sign out
   - Email verification
   - User profile data

2. **BookProvider** - Manages book listings
   - CRUD operations for books
   - Real-time updates via Firestore streams
   - Search functionality

3. **SwapProvider** - Manages swap requests
   - Create, accept, reject swaps
   - Track swap status
   - Update book status based on swap state

4. **ChatProvider** - Manages chat functionality
   - Create/retrieve chats
   - Send messages
   - Real-time message updates

### How Provider Works

```dart
// In main.dart, wrap app with MultiProvider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => BookProvider()),
    ChangeNotifierProvider(create: (_) => SwapProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
  ],
  child: MaterialApp(...),
)

// In widgets, consume provider data
final authProvider = Provider.of<AuthProvider>(context);
// or
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    return Text(authProvider.currentUser?.email ?? '');
  },
)
```

### State Updates Flow

1. User performs action (e.g., posts a book)
2. UI calls provider method (`bookProvider.createBook()`)
3. Provider updates internal state and calls `notifyListeners()`
4. All widgets listening to that provider rebuild with new data
5. Firestore streams keep data in sync across devices

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## Building for Release

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `google-services.json` is in correct location
   - Run `flutter clean` and `flutter pub get`

2. **Email verification not working**
   - Check Firebase Console → Authentication → Templates
   - Ensure email verification is enabled

3. **Images not uploading**
   - Check Firebase Storage rules
   - Ensure proper permissions in AndroidManifest.xml

4. **Build errors**
   - Run `flutter clean`
   - Delete `pubspec.lock`
   - Run `flutter pub get`
   - Restart IDE

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Your Name - [@uwambajeddy](https://github.com/uwambajeddy)

Project Link: [https://github.com/uwambajeddy/book_swap](https://github.com/uwambajeddy/book_swap)

## Acknowledgments

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Google Fonts](https://pub.dev/packages/google_fonts)
