import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';
import '../models/comment_model.dart';
import '../models/message_model.dart';
import 'firebase_service.dart';

class NoteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all notes (feed)
  static Stream<List<NoteModel>> getNotesStream() {
    return _firestore
        .collection('notes')
        .where('isDeleted', isEqualTo: false)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    });
  }

  // Get notes by user
  static Stream<List<NoteModel>> getUserNotesStream(String userId) {
    return _firestore
        .collection('notes')
        .where('authorId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    });
  }

  // Get note by ID
  static Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final doc = await _firestore.collection('notes').doc(noteId).get();
      if (doc.exists) {
        return NoteModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting note: $e');
    }
    return null;
  }

  // Create note
  static Future<NoteModel> createNote({
    required String authorId,
    required String content,
    String? location,
  }) async {
    final docRef = await _firestore.collection('notes').add({
      'authorId': authorId,
      'content': content,
      'location': location,
      'createdAt': Timestamp.now(),
      'likes': [],
      'comments': 0,
      'favorites': [],
      'reports': [],
      'isHidden': false,
      'isDeleted': false,
      'isSystem': false,
    });

    // Update user post count
    await _firestore.collection('users').doc(authorId).update({
      'postCount': FieldValue.increment(1),
    });

    final doc = await docRef.get();
    return NoteModel.fromFirestore(doc);
  }

  // Like note
  static Future<void> likeNote(String noteId, String userId) async {
    final noteRef = _firestore.collection('notes').doc(noteId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(noteRef);
      if (!snapshot.exists) return;

      final likes = List<String>.from(snapshot.data()?['likes'] ?? []);
      
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
        
        // Create notification
        final note = NoteModel.fromFirestore(snapshot);
        if (note.authorId != userId) {
          await _firestore.collection('messages').add({
            'type': 'like',
            'content': '赞了你的动态',
            'toUserId': note.authorId,
            'fromUserId': userId,
            'noteId': noteId,
            'noteContent': note.content.length > 20 
                ? '${note.content.substring(0, 20)}...' 
                : note.content,
            'createdAt': Timestamp.now(),
            'read': false,
          });
        }
      }

      transaction.update(noteRef, {'likes': likes});
    });
  }

  // Favorite note
  static Future<void> favoriteNote(String noteId, String userId) async {
    final noteRef = _firestore.collection('notes').doc(noteId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(noteRef);
      if (!snapshot.exists) return;

      final favorites = List<String>.from(snapshot.data()?['favorites'] ?? []);
      
      if (favorites.contains(userId)) {
        favorites.remove(userId);
      } else {
        favorites.add(userId);
      }

      transaction.update(noteRef, {'favorites': favorites});
    });
  }

  // Delete note
  static Future<void> deleteNote(String noteId, String userId) async {
    final note = await getNoteById(noteId);
    if (note != null && note.authorId == userId) {
      await _firestore.collection('notes').doc(noteId).update({
        'isDeleted': true,
      });
      
      // Update user post count
      await _firestore.collection('users').doc(userId).update({
        'postCount': FieldValue.increment(-1),
      });
    }
  }

  // Get comments
  static Stream<List<CommentModel>> getCommentsStream(String noteId) {
    return _firestore
        .collection('comments')
        .where('noteId', isEqualTo: noteId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList();
    });
  }

  // Add comment
  static Future<void> addComment({
    required String noteId,
    required String authorId,
    required String content,
  }) async {
    // Create comment
    await _firestore.collection('comments').add({
      'noteId': noteId,
      'authorId': authorId,
      'content': content,
      'createdAt': Timestamp.now(),
    });

    // Update note comment count
    await _firestore.collection('notes').doc(noteId).update({
      'comments': FieldValue.increment(1),
    });

    // Create notification
    final note = await getNoteById(noteId);
    if (note != null && note.authorId != authorId) {
      await _firestore.collection('messages').add({
        'type': 'comment',
        'content': content.length > 20 
            ? '${content.substring(0, 20)}...' 
            : content,
        'toUserId': note.authorId,
        'fromUserId': authorId,
        'noteId': noteId,
        'noteContent': note.content.length > 20 
            ? '${note.content.substring(0, 20)}...' 
            : note.content,
        'createdAt': Timestamp.now(),
        'read': false,
      });
    }
  }

  // Get liked notes by user
  static Future<List<NoteModel>> getLikedNotes(String userId) async {
    final query = await _firestore
        .collection('notes')
        .where('likes', arrayContains: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }

  // Get favorited notes by user
  static Future<List<NoteModel>> getFavoritedNotes(String userId) async {
    final query = await _firestore
        .collection('notes')
        .where('favorites', arrayContains: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }
}
