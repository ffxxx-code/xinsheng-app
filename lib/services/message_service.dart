import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message_model.dart';

class MessageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get messages stream
  static Stream<List<MessageModel>> getMessagesStream(String userId) {
    return _firestore
        .collection('messages')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
    });
  }

  // Get unread count
  static Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('messages')
        .where('toUserId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark as read
  static Future<void> markAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'read': true,
    });
  }

  // Mark all as read
  static Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    
    final query = await _firestore
        .collection('messages')
        .where('toUserId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    for (final doc in query.docs) {
      batch.update(doc.reference, {'read': true});
    }

    await batch.commit();
  }

  // Delete message
  static Future<void> deleteMessage(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }
}
