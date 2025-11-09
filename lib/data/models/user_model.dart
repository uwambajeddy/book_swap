import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final bool emailVerified;
  final DateTime createdAt;
  final bool notificationEnabled;
  final bool emailUpdatesEnabled;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.emailVerified = false,
    required this.createdAt,
    this.notificationEnabled = true,
    this.emailUpdatesEnabled = true,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationEnabled': notificationEnabled,
      'emailUpdatesEnabled': emailUpdatesEnabled,
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      notificationEnabled: map['notificationEnabled'] ?? true,
      emailUpdatesEnabled: map['emailUpdatesEnabled'] ?? true,
    );
  }

  // CopyWith method for updating user data
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? emailVerified,
    DateTime? createdAt,
    bool? notificationEnabled,
    bool? emailUpdatesEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      emailUpdatesEnabled: emailUpdatesEnabled ?? this.emailUpdatesEnabled,
    );
  }
}
