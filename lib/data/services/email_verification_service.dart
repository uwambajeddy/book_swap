import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a 4-digit verification code
  String _generateVerificationCode() {
    final random = Random();
    // Generate a number between 1000 and 9999
    final code = 1000 + random.nextInt(9000);
    return code.toString();
  }

  /// Send verification code to user's email
  /// Note: Firebase Auth doesn't support custom email templates directly,
  /// so we'll store the code in Firestore and display it to the user
  /// In production, you'd use a service like SendGrid, Firebase Cloud Functions, or similar
  Future<String> sendVerificationCode(String userId, String email) async {
    try {
      // Generate code
      final code = _generateVerificationCode();
      
      // Calculate expiration time (10 minutes from now)
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));

      // Store code in Firestore
      await _firestore.collection('verification_codes').doc(userId).set({
        'code': code,
        'email': email,
        'expiresAt': expiresAt,
        'verified': false,
        'attempts': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // In a production app, you would send this via email using:
      // - Firebase Cloud Functions with SendGrid/Mailgun
      // - Or a custom email service
      // For now, we'll return the code so it can be displayed/logged
      
      // ignore: avoid_print
      print('Verification code for $email: $code'); // For development only
      
      return code;
    } catch (e) {
      throw Exception('Failed to send verification code: $e');
    }
  }

  /// Verify the code entered by user
  Future<bool> verifyCode(String userId, String enteredCode) async {
    try {
      final docRef = _firestore.collection('verification_codes').doc(userId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('No verification code found. Please request a new code.');
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified = data['verified'] as bool;
      final attempts = data['attempts'] as int;

      // Check if already verified
      if (verified) {
        throw Exception('This code has already been used.');
      }

      // Check if expired
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Verification code has expired. Please request a new code.');
      }

      // Check attempts (max 5 attempts)
      if (attempts >= 5) {
        throw Exception('Too many failed attempts. Please request a new code.');
      }

      // Verify code
      if (storedCode == enteredCode) {
        // Mark as verified
        await docRef.update({
          'verified': true,
          'verifiedAt': FieldValue.serverTimestamp(),
        });

        // Update user's email verification status
        await _firestore.collection('users').doc(userId).update({
          'emailVerified': true,
          'emailVerifiedAt': FieldValue.serverTimestamp(),
        });

        return true;
      } else {
        // Increment attempts
        await docRef.update({
          'attempts': FieldValue.increment(1),
        });
        throw Exception('Invalid verification code. ${4 - attempts} attempts remaining.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to verify code: $e');
    }
  }

  /// Resend verification code
  Future<String> resendVerificationCode(String userId, String email) async {
    try {
      // Delete old code
      await _firestore.collection('verification_codes').doc(userId).delete();
      
      // Send new code
      return await sendVerificationCode(userId, email);
    } catch (e) {
      throw Exception('Failed to resend verification code: $e');
    }
  }

  /// Check if user has a valid verification code
  Future<bool> hasValidCode(String userId) async {
    try {
      final doc = await _firestore.collection('verification_codes').doc(userId).get();
      
      if (!doc.exists) return false;
      
      final data = doc.data()!;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified = data['verified'] as bool;
      
      return !verified && DateTime.now().isBefore(expiresAt);
    } catch (e) {
      return false;
    }
  }

  /// Get remaining time for code expiration
  Future<Duration?> getRemainingTime(String userId) async {
    try {
      final doc = await _firestore.collection('verification_codes').doc(userId).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final verified = data['verified'] as bool;
      
      if (verified) return null;
      
      final remaining = expiresAt.difference(DateTime.now());
      return remaining.isNegative ? null : remaining;
    } catch (e) {
      return null;
    }
  }
}
