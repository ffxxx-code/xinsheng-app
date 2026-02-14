# 心声 - 极简笔记社区 Flutter App

一个基于 Flutter + Firebase 的跨平台社交应用，支持 iOS 和 Android。

## 功能特性

### 核心功能
- 📱 **用户系统**：注册、登录、忘记密码、账号资料管理
- 📝 **动态发布**：发布50字以内的文字动态，支持位置标记
- ❤️ **互动功能**：点赞、评论、收藏、关注
- 🔔 **消息通知**：实时接收点赞、评论、关注通知
- 👤 **个人主页**：查看个人资料、动态、关注列表

### 新增功能
- ✨ **骨架屏加载**：优雅的加载动画体验
- 🔄 **下拉刷新/上拉加载**：流畅的列表刷新体验
- 📊 **用户数据看板**：展示用户统计数据和趋势
- 🎬 **动画效果**：页面切换、列表项动画、点赞动画
- 📤 **分享功能**：分享动态、用户主页、应用
- 🔔 **推送通知**：Firebase Cloud Messaging 推送

## 技术栈

- **框架**：Flutter 3.x
- **状态管理**：Riverpod
- **路由管理**：Go Router
- **后端服务**：Firebase
  - Firebase Authentication（用户认证）
  - Cloud Firestore（数据库）
  - Firebase Storage（文件存储）
  - Firebase Cloud Messaging（推送通知）
  - Firebase Crashlytics（崩溃监控）
  - Firebase Analytics（数据分析）
- **UI组件**：Material Design 3
- **本地存储**：Shared Preferences

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── app.dart                  # 应用配置
├── firebase_options.dart     # Firebase 配置
├── models/                   # 数据模型
│   ├── user_model.dart
│   ├── note_model.dart
│   ├── comment_model.dart
│   ├── message_model.dart
│   └── notification_model.dart
├── services/                 # 业务服务
│   ├── auth_service.dart
│   ├── note_service.dart
│   ├── user_service.dart
│   ├── message_service.dart
│   ├── notification_service.dart
│   └── share_service.dart
├── providers/                # 状态管理
│   ├── auth_provider.dart
│   ├── note_provider.dart
│   ├── message_provider.dart
│   └── theme_provider.dart
├── screens/                  # 页面
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── forgot_password_screen.dart
│   ├── main_screen.dart
│   ├── feed_screen.dart
│   ├── publish_screen.dart
│   ├── messages_screen.dart
│   ├── profile_screen.dart
│   └── ...
├── widgets/                  # 组件
│   ├── skeleton_widgets.dart    # 骨架屏
│   ├── animated_widgets.dart    # 动画组件
│   ├── refresh_widgets.dart     # 刷新组件
│   ├── user_dashboard.dart      # 用户数据看板
│   ├── note_card.dart
│   └── avatar_widget.dart
├── router/                   # 路由
│   └── app_router.dart
├── theme/                    # 主题
│   └── app_theme.dart
└── utils/                    # 工具函数
    └── utils.dart
```

## 环境配置

### 1. 安装 Flutter

确保已安装 Flutter SDK（版本 >= 3.0.0）：

```bash
flutter doctor
```

### 2. 配置 Firebase

#### 方式一：使用 FlutterFire CLI（推荐）

1. 安装 FlutterFire CLI：
```bash
dart pub global activate flutterfire_cli
```

2. 登录 Firebase：
```bash
firebase login
```

3. 配置 Firebase：
```bash
flutterfire configure
```

#### 方式二：手动配置

1. 在 [Firebase Console](https://console.firebase.google.com/) 创建新项目
2. 添加 Android 应用（包名：`com.xinsheng.xinsheng`）
3. 添加 iOS 应用（Bundle ID：`com.xinsheng.xinsheng`）
4. 下载配置文件：
   - Android：`google-services.json` → 放到 `android/app/`
   - iOS：`GoogleService-Info.plist` → 放到 `ios/Runner/`
5. 更新 `lib/firebase_options.dart` 中的配置

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 运行应用

```bash
# 开发模式
flutter run

# 指定设备
flutter run -d <device_id>

# 发布模式
flutter run --release
```

## 构建发布版本

### Android

```bash
# APK
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

然后在 Xcode 中打开 `ios/Runner.xcworkspace` 进行签名和发布。

## Firebase 安全规则

### Firestore 安全规则

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用户集合
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 动态集合
    match /notes/{noteId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.authorId == request.auth.uid;
    }
    
    // 评论集合
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow delete: if request.auth != null && 
        resource.data.authorId == request.auth.uid;
    }
    
    // 消息集合
    match /messages/{messageId} {
      allow read: if request.auth != null && 
        resource.data.toUserId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        resource.data.toUserId == request.auth.uid;
      allow delete: if request.auth != null && 
        resource.data.toUserId == request.auth.uid;
    }
  }
}
```

### Storage 安全规则

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 用户系统说明

### 注册流程
1. 输入用户名和昵称
2. 绑定手机号
3. 设置密码（至少6位）

### 登录方式
- 用户名 + 密码登录

### 忘记密码
1. 输入手机号
2. 验证验证码（演示模式固定为 123456）
3. 设置新密码

## 推送通知配置

### Android

1. 在 Firebase Console 下载 `google-services.json`
2. 在 `android/app/build.gradle` 中配置：
```gradle
defaultConfig {
    applicationId "com.xinsheng.xinsheng"
    minSdkVersion 21
    targetSdkVersion 34
    // ...
}
```

### iOS

1. 在 Firebase Console 下载 `GoogleService-Info.plist`
2. 在 Xcode 中开启 Push Notifications 功能
3. 配置 APNs 证书

## 常见问题

### Q: 如何修改 Firebase 配置？
A: 运行 `flutterfire configure` 或手动编辑 `lib/firebase_options.dart`

### Q: 如何添加新的依赖？
A: 在 `pubspec.yaml` 中添加依赖，然后运行 `flutter pub get`

### Q: 如何调试推送通知？
A: 使用 Firebase Console 的 Cloud Messaging 功能发送测试消息

### Q: 如何查看崩溃日志？
A: 在 Firebase Console 的 Crashlytics 面板查看

## 许可证

MIT License

## 联系方式

如有问题或建议，请通过应用内的意见反馈功能联系我们。
