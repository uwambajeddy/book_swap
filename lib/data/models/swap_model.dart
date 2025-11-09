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
  final String ownerId; // Owner of the book
  final String ownerName;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookImageUrl;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SwapModel({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookImageUrl,
    this.status = SwapStatus.pending,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookImageUrl': bookImageUrl,
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
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      bookId: map['bookId'] ?? '',
      bookTitle: map['bookTitle'] ?? '',
      bookAuthor: map['bookAuthor'] ?? '',
      bookImageUrl: map['bookImageUrl'],
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
    String? ownerId,
    String? ownerName,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookImageUrl,
    SwapStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SwapModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
