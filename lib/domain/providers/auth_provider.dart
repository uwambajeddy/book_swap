import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  UserModel? _currentUserData;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  UserModel? get currentUserData => _currentUserData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  // Check authentication - user just needs to be signed in
  bool get isAuthenticated => _currentUser != null;
  // Check if email is verified
  bool get isEmailVerified => _currentUser != null && _currentUser!.emailVerified;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        // Validate user exists in Firestore
        try {
          await _loadUserData(user.uid);
        } catch (e) {
          // Retry once after a short delay (for new sign-ups)
          print('⚠️ First attempt failed, retrying after delay...');
          await Future.delayed(const Duration(milliseconds: 1500));
          
          try {
            await _loadUserData(user.uid);
          } catch (retryError) {
            // User doesn't exist in Firestore after retry, sign them out
            print('❌ User data not found after retry, signing out');
            await _authService.signOut();
            _currentUser = null;
            _currentUserData = null;
          }
        }
      } else {
        _currentUserData = null;
      }
      notifyListeners();
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      final userData = await _authService.getUserData(userId);
      
      if (userData == null) {
        // User document doesn't exist in Firestore
        print('⚠️ User document not found in Firestore for user: $userId');
        throw 'User data not found. Please contact support.';
      }
      
      _currentUserData = userData;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user data: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Public method to manually reload user data
  Future<void> loadUserData() async {
    if (_currentUser != null) {
      await _loadUserData(_currentUser!.uid);
    }
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signIn(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();

      _currentUser = null;
      _currentUserData = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Check email verification
  Future<bool> checkEmailVerification() async {
    try {
      bool isVerified = await _authService.isEmailVerified();
      
      // Reload current user to get updated emailVerified status
      if (_currentUser != null) {
        await _currentUser!.reload();
        _currentUser = _authService.currentUser;
      }
      
      if (isVerified && _currentUser != null) {
        await _loadUserData(_currentUser!.uid);
      }
      
      // Notify listeners to update UI
      notifyListeners();
      
      return isVerified;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel userData) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateUserData(userData);
      _currentUserData = userData;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? notificationEnabled,
    bool? emailUpdatesEnabled,
  }) async {
    if (_currentUserData == null) return;

    try {
      UserModel updatedUser = _currentUserData!.copyWith(
        notificationEnabled: notificationEnabled ?? _currentUserData!.notificationEnabled,
        emailUpdatesEnabled: emailUpdatesEnabled ?? _currentUserData!.emailUpdatesEnabled,
      );

      await updateUserData(updatedUser);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete account and all associated data
  Future<bool> deleteAccount() async {
    if (_currentUser == null) {
      _errorMessage = 'No user is currently signed in.';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.deleteAccount(_currentUser!.uid);

      // Clear local state
      _currentUser = null;
      _currentUserData = null;
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
