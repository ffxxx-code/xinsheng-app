import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String authorId;
  final String content;
  final String? location;
  final DateTime createdAt;
  final List<String> likes;
  final int comments;
  final List<String> favorites;
  final List<String> reports;
  final bool isHidden;
  final bool isDeleted;
  final bool isSystem;

  NoteModel({
    required this.id,
    required this.authorId,
    required this.content,
    this.location,
    required this.createdAt,
    this.likes = const [],
    this.comments = 0,
    this.favorites = const [],
    this.reports = const [],
    this.isHidden = false,
    this.isDeleted = false,
    this.isSystem = false,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      comments: data['comments'] ?? 0,
      favorites: List<String>.from(data['favorites'] ?? []),
      reports: List<String>.from(data['reports'] ?? []),
      isHidden: data['isHidden'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      isSystem: data['isSystem'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'content': content,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'comments': comments,
      'favorites': favorites,
      'reports': reports,
      'isHidden': isHidden,
      'isDeleted': isDeleted,
      'isSystem': isSystem,
    };
  }

  NoteModel copyWith({
    String? id,
    String? authorId,
    String? content,
    String? location,
    DateTime? createdAt,
    List<String>? likes,
    int? comments,
    List<String>? favorites,
    List<String>? reports,
    bool? isHidden,
    bool? isDeleted,
    bool? isSystem,
  }) {
    return NoteModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      favorites: favorites ?? this.favorites,
      reports: reports ?? this.reports,
      isHidden: isHidden ?? this.isHidden,
      isDeleted: isDeleted ?? this.isDeleted,
      isSystem: isSystem ?? this.isSystem,
    );
  }
}
