import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth
  static FirebaseAuth get auth => _auth;
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firestore Collections
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get notesCollection => _firestore.collection('notes');
  static CollectionReference get commentsCollection => _firestore.collection('comments');
  static CollectionReference get messagesCollection => _firestore.collection('messages');

  // Initialize system data
  static Future<void> initializeSystemData() async {
    // Check if feedback note exists
    final feedbackQuery = await notesCollection
        .where('isSystem', isEqualTo: true)
        .where('authorId', isEqualTo: 'system')
        .limit(1)
        .get();

    if (feedbackQuery.docs.isEmpty) {
      // Create system user
      final systemUserDoc = await usersCollection.doc('system').get();
      if (!systemUserDoc.exists) {
        await usersCollection.doc('system').set({
          'username': 'xinsheng_admin',
          'nickname': '心声小助手',
          'phone': '13800000000',
          'createdAt': Timestamp.now(),
          'postCount': 1,
          'violationCount': 0,
          'following': [],
          'followers': [],
          'isDisabled': false,
        });
      }

      // Create feedback note
      await notesCollection.add({
        'authorId': 'system',
        'content': '👋 欢迎来到心声！\n\n这里是意见反馈专区，如果你有任何建议、问题或想法，欢迎在下方评论区留言。我们会认真阅读每一条反馈，不断改进产品体验。\n\n💡 你可以反馈：\n• 使用过程中的问题\n• 功能建议\n• 界面优化建议\n• 其他任何想法\n\n感谢你的支持！',
        'location': '心声总部',
        'createdAt': Timestamp.now(),
        'likes': [],
        'comments': 0,
        'favorites': [],
        'reports': [],
        'isHidden': false,
        'isDeleted': false,
        'isSystem': true,
      });
    }
  }

  // Create system message for new user
  static Future<void> createSystemMessageForUser(String userId) async {
    final feedbackNote = await notesCollection
        .where('isSystem', isEqualTo: true)
        .where('authorId', isEqualTo: 'system')
        .limit(1)
        .get();

    if (feedbackNote.docs.isNotEmpty) {
      await messagesCollection.add({
        'type': 'system',
        'content': '欢迎来到心声！如有任何问题或建议，欢迎到意见反馈专区留言。',
        'toUserId': userId,
        'noteId': feedbackNote.docs.first.id,
        'noteContent': '意见反馈专区',
        'createdAt': Timestamp.now(),
        'read': false,
      });
    }
  }
}
