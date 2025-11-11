import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapStatus {
  pending,
  accepted,
  rejected;

  String get displayName {
    switch (this) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.accepted:
        return 'Accepted';
      case SwapStatus.rejected:
        return 'Rejected';
    }
  }

  static SwapStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return SwapStatus.pending;
      case 'accepted':
        return SwapStatus.accepted;
      case 'rejected':
        return SwapStatus.rejected;
      default:
        return SwapStatus.pending;
    }
  }
}

class SwapModel {
  final String id;
  final String requesterId; // User who initiated the swap
  final String requesterName;
  final String requesterBookId; // Book the requester is offering
  final String requesterBookTitle;
  final String requesterBookAuthor;
  final String? requesterBookImageUrl;
  final String ownerId; // Owner of the book being requested
  final String ownerName;
  final String ownerBookId; // Book being requested
  final String ownerBookTitle;
  final String ownerBookAuthor;
  final String? ownerBookImageUrl;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SwapModel({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterBookId,
    required this.requesterBookTitle,
    required this.requesterBookAuthor,
    this.requesterBookImageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.ownerBookId,
    required this.ownerBookTitle,
    required this.ownerBookAuthor,
    this.ownerBookImageUrl,
    this.status = SwapStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterBookId': requesterBookId,
      'requesterBookTitle': requesterBookTitle,
      'requesterBookAuthor': requesterBookAuthor,
      'requesterBookImageUrl': requesterBookImageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerBookId': ownerBookId,
      'ownerBookTitle': ownerBookTitle,
      'ownerBookAuthor': ownerBookAuthor,
      'ownerBookImageUrl': ownerBookImageUrl,
      'status': status.displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory SwapModel.fromMap(Map<String, dynamic> map) {
    return SwapModel(
      id: map['id'] ?? '',
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'] ?? '',
      requesterBookId: map['requesterBookId'] ?? map['bookId'] ?? '', // Fallback for old data
      requesterBookTitle: map['requesterBookTitle'] ?? map['bookTitle'] ?? '',
      requesterBookAuthor: map['requesterBookAuthor'] ?? map['bookAuthor'] ?? '',
      requesterBookImageUrl: map['requesterBookImageUrl'] ?? map['bookImageUrl'],
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      ownerBookId: map['ownerBookId'] ?? map['bookId'] ?? '', // Fallback for old data
      ownerBookTitle: map['ownerBookTitle'] ?? map['bookTitle'] ?? '',
      ownerBookAuthor: map['ownerBookAuthor'] ?? map['bookAuthor'] ?? '',
      ownerBookImageUrl: map['ownerBookImageUrl'] ?? map['bookImageUrl'],
      status: SwapStatus.fromString(map['status'] ?? 'Pending'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt:
          map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  SwapModel copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterBookId,
    String? requesterBookTitle,
    String? requesterBookAuthor,
    String? requesterBookImageUrl,
    String? ownerId,
    String? ownerName,
    String? ownerBookId,
    String? ownerBookTitle,
    String? ownerBookAuthor,
    String? ownerBookImageUrl,
    SwapStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SwapModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterBookId: requesterBookId ?? this.requesterBookId,
      requesterBookTitle: requesterBookTitle ?? this.requesterBookTitle,
      requesterBookAuthor: requesterBookAuthor ?? this.requesterBookAuthor,
      requesterBookImageUrl: requesterBookImageUrl ?? this.requesterBookImageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerBookId: ownerBookId ?? this.ownerBookId,
      ownerBookTitle: ownerBookTitle ?? this.ownerBookTitle,
      ownerBookAuthor: ownerBookAuthor ?? this.ownerBookAuthor,
      ownerBookImageUrl: ownerBookImageUrl ?? this.ownerBookImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
