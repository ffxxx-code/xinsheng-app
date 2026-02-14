import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String nickname;
  final String? phone;
  final String? email;
  final String? avatar;
  final String? bio;
  final DateTime createdAt;
  final int postCount;
  final int violationCount;
  final List<String> following;
  final List<String> followers;
  final List<String> likesGiven;
  final List<String> favorites;
  final bool isDisabled;

  UserModel({
    required this.id,
    required this.username,
    required this.nickname,
    this.phone,
    this.email,
    this.avatar,
    this.bio,
    required this.createdAt,
    this.postCount = 0,
    this.violationCount = 0,
    this.following = const [],
    this.followers = const [],
    this.likesGiven = const [],
    this.favorites = const [],
    this.isDisabled = false,
  });

  /// 获取关注数量
  int get followingCount => following.length;

  /// 获取粉丝数量
  int get followersCount => followers.length;

  /// 获取动态数量
  int get postsCount => postCount;

  /// 获取获赞数量（从粉丝列表计算）
  int get likesReceived => followers.length * 3; // 模拟计算

  /// 获取点赞数量
  int get likesCount => likesGiven.length;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      nickname: data['nickname'] ?? '',
      phone: data['phone'],
      email: data['email'],
      avatar: data['avatar'],
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postCount: data['postCount'] ?? 0,
      violationCount: data['violationCount'] ?? 0,
      following: List<String>.from(data['following'] ?? []),
      followers: List<String>.from(data['followers'] ?? []),
      likesGiven: List<String>.from(data['likesGiven'] ?? []),
      favorites: List<String>.from(data['favorites'] ?? []),
      isDisabled: data['isDisabled'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'nickname': nickname,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'postCount': postCount,
      'violationCount': violationCount,
      'following': following,
      'followers': followers,
      'likesGiven': likesGiven,
      'favorites': favorites,
      'isDisabled': isDisabled,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? nickname,
    String? phone,
    String? email,
    String? avatar,
    String? bio,
    DateTime? createdAt,
    int? postCount,
    int? violationCount,
    List<String>? following,
    List<String>? followers,
    List<String>? likesGiven,
    List<String>? favorites,
    bool? isDisabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      postCount: postCount ?? this.postCount,
      violationCount: violationCount ?? this.violationCount,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      likesGiven: likesGiven ?? this.likesGiven,
      favorites: favorites ?? this.favorites,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}
