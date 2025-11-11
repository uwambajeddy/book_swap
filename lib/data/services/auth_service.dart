import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      try {
        await userCredential.user!.sendEmailVerification();
        print('✅ Email verification sent successfully to: $email');
      } catch (emailError) {
        print('❌ Failed to send verification email: $emailError');
        // Don't throw error here, continue with user creation
        // The user can resend the verification email later
      }

      // Create user document in Firestore
      UserModel userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        emailVerified: false,
        createdAt: DateTime.now(),
      );

      print('📝 Creating user document in Firestore...');
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());
      
      print('✅ User document created successfully in Firestore');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting to sign in: $email');
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Sign in successful. User ID: ${userCredential.user!.uid}');
      print('📧 Email verified: ${userCredential.user!.emailVerified}');

      // Check if user document exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        print('⚠️ User document missing in Firestore. Creating...');
        
        // Create missing user document
        UserModel userModel = UserModel(
          id: userCredential.user!.uid,
          email: email,
          fullName: userCredential.user!.displayName ?? email.split('@')[0],
          emailVerified: userCredential.user!.emailVerified,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toMap());
            
        print('✅ User document created in Firestore');
      } else {
        print('✅ User document exists in Firestore');
        
        // Update email verification status if verified
        if (userCredential.user!.emailVerified) {
          try {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .update({'emailVerified': true});
            print('✅ Updated email verification status');
          } catch (updateError) {
            print('⚠️ Failed to update verification status: $updateError');
          }
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Sign in failed with FirebaseAuthException: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Sign in failed with error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error signing out: $e';
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }
      
      if (user.emailVerified) {
        throw 'Email is already verified.';
      }
      
      print('📧 Attempting to send verification email to: ${user.email}');
      print('📧 User ID: ${user.uid}');
      print('📧 Email verified status: ${user.emailVerified}');
      
      await user.sendEmailVerification();
      
      print('✅ Email verification sent successfully!');
      print('✅ Check your email: ${user.email}');
      print('✅ Note: It may take a few minutes to arrive. Check spam folder.');
    } catch (e) {
      print('❌ Error sending verification email: $e');
      throw 'Error sending verification email: $e';
    }
  }

  // Reload user to check email verification status
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw 'Error reloading user: $e';
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await reloadUser();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      print('📥 Fetching user data for ID: $userId');
      
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        print('✅ User document found in Firestore');
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      
      print('⚠️ User document does NOT exist in Firestore');
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      throw 'Error getting user data: $e';
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw 'Error updating user data: $e';
    }
  }

  // Stream of user data
  Stream<UserModel?> streamUserData(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error sending password reset email: $e';
    }
  }

  // Delete user account and all associated data
  Future<void> deleteAccount(String userId) async {
    try {
      print('🗑️ Starting account deletion for user: $userId');
      
      // 1. Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();
      print('✅ User document deleted');
      
      // 2. Delete user's books
      final booksSnapshot = await _firestore
          .collection('books')
          .where('ownerId', isEqualTo: userId)
          .get();
      
      for (var doc in booksSnapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Deleted ${booksSnapshot.docs.length} books');
      
      // 3. Delete swap requests where user is requester or owner
      final swapsAsRequester = await _firestore
          .collection('swaps')
          .where('requesterId', isEqualTo: userId)
          .get();
      
      for (var doc in swapsAsRequester.docs) {
        await doc.reference.delete();
      }
      
      final swapsAsOwner = await _firestore
          .collection('swaps')
          .where('ownerId', isEqualTo: userId)
          .get();
      
      for (var doc in swapsAsOwner.docs) {
        await doc.reference.delete();
      }
      print('✅ Deleted ${swapsAsRequester.docs.length + swapsAsOwner.docs.length} swap requests');
      
      // 4. Delete chats where user is participant
      final chatsSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();
      
      for (var doc in chatsSnapshot.docs) {
        // Delete messages subcollection
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .get();
        
        for (var messageDoc in messagesSnapshot.docs) {
          await messageDoc.reference.delete();
        }
        
        // Delete chat document
        await doc.reference.delete();
      }
      print('✅ Deleted ${chatsSnapshot.docs.length} chats');
      
      // 5. Finally, delete Firebase Auth user
      await _auth.currentUser?.delete();
      print('✅ Firebase Auth user deleted');
      
      print('✅ Account deletion completed successfully');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Please sign in again before deleting your account.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Error deleting account: $e');
      throw 'Error deleting account: $e';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
