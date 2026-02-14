import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with phone
  static Future<UserModel?> register({
    required String username,
    required String nickname,
    required String phone,
    required String password,
  }) async {
    try {
      // Check if username exists
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw Exception('用户名已被使用');
      }

      // Check if phone exists
      final phoneQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        throw Exception('手机号已被注册');
      }

      // Create auth user with phone (using phone as email for Firebase Auth)
      final email = '$phone@xinsheng.app';
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user document
        final user = UserModel(
          id: credential.user!.uid,
          username: username,
          nickname: nickname,
          phone: phone,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set(user.toFirestore());

        // Create system message
        await FirebaseService.createSystemMessageForUser(user.id);

        return user;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
    return null;
  }

  // Login
  static Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    try {
      // Find user by username
      final userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('用户名或密码错误');
      }

      final userData = userQuery.docs.first.data();
      final phone = userData['phone'] as String?;

      if (phone == null) {
        throw Exception('账号信息不完整');
      }

      // Login with phone (as email)
      final email = '$phone@xinsheng.app';
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
    return null;
  }

  // Reset password
  static Future<void> resetPassword({
    required String phone,
    required String newPassword,
  }) async {
    try {
      // Find user by phone
      final userQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('该手机号未注册');
      }

      final email = '$phone@xinsheng.app';
      
      // For demo, we need to re-authenticate to change password
      // In production, this should use Firebase phone auth verification
      final user = _auth.currentUser;
      if (user != null && user.email == email) {
        await user.updatePassword(newPassword);
      } else {
        // For demo purposes, we'll update the password through admin SDK
        // In production, use proper phone verification
        throw Exception('请先登录后再修改密码');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update user profile
  static Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Change phone
  static Future<void> changePhone({
    required String userId,
    required String newPhone,
  }) async {
    try {
      // Check if phone exists
      final phoneQuery = await _firestore
          .collection('users')
          .where('phone', isEqualTo: newPhone)
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        throw Exception('该手机号已被绑定');
      }

      await _firestore.collection('users').doc(userId).update({
        'phone': newPhone,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user by ID
  static Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  // Get user by username
  static Future<UserModel?> getUserByUsername(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromFirestore(query.docs.first);
      }
    } catch (e) {
      print('Error getting user: $e');
    }
    return null;
  }

  // Error messages
  static String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return '邮箱格式不正确';
      case 'user-disabled':
        return '账号已被禁用';
      case 'user-not-found':
        return '用户不存在';
      case 'wrong-password':
        return '密码错误';
      case 'email-already-in-use':
        return '该邮箱已被注册';
      case 'weak-password':
        return '密码强度不够';
      case 'invalid-credential':
        return '用户名或密码错误';
      default:
        return e.message ?? '登录失败';
    }
  }
}
