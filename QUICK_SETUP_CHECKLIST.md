# Firebase 配置快速检查清单

## 当前状态

| 项目 | 状态 | 说明 |
|------|------|------|
| ✅ Android 配置文件 | 已完成 | `android/app/google-services.json` |
| ✅ iOS 配置文件 | 已完成 | `ios/Runner/GoogleService-Info.plist` |
| ✅ Firebase 配置代码 | 已完成 | `lib/firebase_options.dart` |
| ✅ Android 项目配置 | 已完成 | `build.gradle`, `AndroidManifest.xml` |
| ✅ iOS 项目配置 | 已完成 | `Podfile`, `Info.plist` |
| ⬜ Firebase Console 配置 | 需要你完成 | 见下方步骤 |

---

## 你需要在 Firebase Console 完成的 4 件事

### 1️⃣ 启用 Authentication（2分钟）
```
Firebase Console → Authentication → 开始使用 → 电子邮件/密码 → 启用
```

### 2️⃣ 创建 Firestore Database（3分钟）
```
Firebase Console → Firestore Database → 创建数据库 → 测试模式 → 启用
→ 规则 → 粘贴安全规则 → 发布
```

**安全规则代码**（复制粘贴）：
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /notes/{noteId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
    match /messages/{messageId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.senderId || request.auth.uid == resource.data.receiverId);
      allow create: if request.auth != null && request.auth.uid == request.resource.data.senderId;
    }
    match /notifications/{notificationId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create, update: if request.auth != null;
    }
    match /chatRooms/{chatRoomId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid in resource.data.participants;
    }
  }
}
```

### 3️⃣ 启用 Storage（2分钟）
```
Firebase Console → Storage → 开始使用 → 测试模式 → 完成
→ 规则 → 粘贴安全规则 → 发布
```

**安全规则代码**（复制粘贴）：
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /avatars/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /notes/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /chat/{chatRoomId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 4️⃣ 配置 Cloud Messaging（可选，3分钟）
- Android 推送：自动完成 ✅
- iOS 推送：需要 Apple Developer 账号配置 APNs（可选）

---

## 运行 APP

完成以上配置后：

```bash
cd /mnt/okcomputer/output/xinsheng_app
flutter pub get
flutter run
```

---

## 预计总耗时

- Firebase Console 配置：**7-10 分钟**
- 首次运行编译：**3-5 分钟**

**总共约 15 分钟后，APP 就能正常运行了！**
