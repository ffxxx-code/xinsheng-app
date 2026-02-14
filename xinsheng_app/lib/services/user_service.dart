import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Follow user
  static Future<void> followUser(String currentUserId, String targetUserId) async {
    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final targetUserRef = _firestore.collection('users').doc(targetUserId);

    await _firestore.runTransaction((transaction) async {
      final currentUserDoc = await transaction.get(currentUserRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      if (!currentUserDoc.exists || !targetUserDoc.exists) return;

      final currentFollowing = List<String>.from(
        currentUserDoc.data()?['following'] ?? [],
      );
      final targetFollowers = List<String>.from(
        targetUserDoc.data()?['followers'] ?? [],
      );

      if (currentFollowing.contains(targetUserId)) {
        // Unfollow
        currentFollowing.remove(targetUserId);
        targetFollowers.remove(currentUserId);
      } else {
        // Follow
        currentFollowing.add(targetUserId);
        targetFollowers.add(currentUserId);

        // Create notification
        await _firestore.collection('messages').add({
          'type': 'follow',
          'content': '关注了你',
          'toUserId': targetUserId,
          'fromUserId': currentUserId,
          'createdAt': Timestamp.now(),
          'read': false,
        });
      }

      transaction.update(currentUserRef, {'following': currentFollowing});
      transaction.update(targetUserRef, {'followers': targetFollowers});
    });
  }

  // Get following users
  static Future<List<UserModel>> getFollowingUsers(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];

    final following = List<String>.from(userDoc.data()?['following'] ?? []);
    if (following.isEmpty) return [];

    final query = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: following)
        .get();

    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Get followers
  static Future<List<UserModel>> getFollowers(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];

    final followers = List<String>.from(userDoc.data()?['followers'] ?? []);
    if (followers.isEmpty) return [];

    final query = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: followers)
        .get();

    return query.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // Update nickname
  static Future<void> updateNickname(String userId, String newNickname) async {
    await _firestore.collection('users').doc(userId).update({
      'nickname': newNickname,
    });
  }

  // Update username
  static Future<void> updateUsername(String userId, String newUsername) async {
    // Check if username exists
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: newUsername)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty && query.docs.first.id != userId) {
      throw Exception('该用户名已被使用');
    }

    await _firestore.collection('users').doc(userId).update({
      'username': newUsername,
    });
  }

  // Update phone
  static Future<void> updatePhone(String userId, String newPhone) async {
    // Check if phone exists
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: newPhone)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty && query.docs.first.id != userId) {
      throw Exception('该手机号已被绑定');
    }

    await _firestore.collection('users').doc(userId).update({
      'phone': newPhone,
    });
  }

  // Update avatar
  static Future<void> updateAvatar(String userId, String avatarPath) async {
    await _firestore.collection('users').doc(userId).update({
      'avatar': avatarPath,
    });
  }

  // Search users
  static Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final usernameQuery = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: '${query}z')
        .limit(20)
        .get();

    final nicknameQuery = await _firestore
        .collection('users')
        .where('nickname', isGreaterThanOrEqualTo: query)
        .where('nickname', isLessThan: '${query}z')
        .limit(20)
        .get();

    final results = <String, UserModel>{};
    
    for (final doc in usernameQuery.docs) {
      results[doc.id] = UserModel.fromFirestore(doc);
    }
    
    for (final doc in nicknameQuery.docs) {
      results[doc.id] = UserModel.fromFirestore(doc);
    }

    return results.values.toList();
  }
}
