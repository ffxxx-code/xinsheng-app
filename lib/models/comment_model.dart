import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String noteId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.noteId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      noteId: data['noteId'] ?? '',
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'noteId': noteId,
      'authorId': authorId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
