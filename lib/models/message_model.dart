import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  comment,
  like,
  follow,
  system,
}

class MessageModel {
  final String id;
  final MessageType type;
  final String content;
  final String toUserId;
  final String? fromUserId;
  final String? noteId;
  final String? noteContent;
  final DateTime createdAt;
  final bool read;

  MessageModel({
    required this.id,
    required this.type,
    required this.content,
    required this.toUserId,
    this.fromUserId,
    this.noteId,
    this.noteContent,
    required this.createdAt,
    this.read = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.system,
      ),
      content: data['content'] ?? '',
      toUserId: data['toUserId'] ?? '',
      fromUserId: data['fromUserId'],
      noteId: data['noteId'],
      noteContent: data['noteContent'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'content': content,
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'noteId': noteId,
      'noteContent': noteContent,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
    };
  }

  MessageModel copyWith({
    String? id,
    MessageType? type,
    String? content,
    String? toUserId,
    String? fromUserId,
    String? noteId,
    String? noteContent,
    DateTime? createdAt,
    bool? read,
  }) {
    return MessageModel(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      toUserId: toUserId ?? this.toUserId,
      fromUserId: fromUserId ?? this.fromUserId,
      noteId: noteId ?? this.noteId,
      noteContent: noteContent ?? this.noteContent,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}
