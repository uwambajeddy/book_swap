import 'package:cloud_firestore/cloud_firestore.dart';

enum BookCondition {
  newCondition,
  likeNew,
  good,
  used;

  String get displayName {
    switch (this) {
      case BookCondition.newCondition:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }

  static BookCondition fromString(String value) {
    switch (value.toLowerCase()) {
      case 'new':
        return BookCondition.newCondition;
      case 'like new':
        return BookCondition.likeNew;
      case 'good':
        return BookCondition.good;
      case 'used':
        return BookCondition.used;
      default:
        return BookCondition.used;
    }
  }
}

enum BookStatus {
  available,
  pending,
  swapped;

  String get displayName {
    switch (this) {
      case BookStatus.available:
        return 'Available';
      case BookStatus.pending:
        return 'Pending';
      case BookStatus.swapped:
        return 'Swapped';
    }
  }

  static BookStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'available':
        return BookStatus.available;
      case 'pending':
        return BookStatus.pending;
      case 'swapped':
        return BookStatus.swapped;
      default:
        return BookStatus.available;
    }
  }
}

class BookModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String title;
  final String author;
  final String swapFor;
  final BookCondition condition;
  final BookStatus status;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.title,
    required this.author,
    required this.swapFor,
    required this.condition,
    this.status = BookStatus.available,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'title': title,
      'author': author,
      'swapFor': swapFor,
      'condition': condition.displayName,
      'status': status.displayName,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      swapFor: map['swapFor'] ?? '',
      condition: BookCondition.fromString(map['condition'] ?? 'Used'),
      status: BookStatus.fromString(map['status'] ?? 'Available'),
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt:
          map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  BookModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? title,
    String? author,
    String? swapFor,
    BookCondition? condition,
    BookStatus? status,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      title: title ?? this.title,
      author: author ?? this.author,
      swapFor: swapFor ?? this.swapFor,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
