# Firebase 配置完整指南

## 配置状态

| 配置项 | 状态 |
|--------|------|
| Android 配置文件 (google-services.json) | ✅ 已配置 |
| iOS 配置文件 (GoogleService-Info.plist) | ✅ 已配置 |
| Firebase 配置代码 (firebase_options.dart) | ✅ 已配置 |
| Android 项目配置 | ✅ 已配置 |
| iOS 项目配置 | ✅ 已配置 |
| Firebase Console 后台配置 | ⬜ 需要你完成 |

---

## 已完成的配置

### 1. Android 配置

文件位置：`android/app/google-services.json`

```json
{
  "project_info": {
    "project_number": "504967530478",
    "project_id": "xinsheng-app",
    "storage_bucket": "xinsheng-app.firebasestorage.app"
  },
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "1:504967530478:android:6f3ac4da62392b276b70ff",
      "android_client_info": {
        "package_name": "com.xinsheng.xinsheng"
      }
    },
    "api_key": [{"current_key": "AIzaSyCtci-Q1x-jytAXZSt96dyBq7L5uf9oBkY"}]
  }]
}
```

### 2. iOS 配置

文件位置：`ios/Runner/GoogleService-Info.plist`

```xml
- API_KEY: AIzaSyAfVYYl8vMZlm_4dNF5IvSixn5mAtmvclI
- GCM_SENDER_ID: 504967530478
- BUNDLE_ID: com.xinsheng.xinsheng
- PROJECT_ID: xinsheng-app
- GOOGLE_APP_ID: 1:504967530478:ios:a14fc0f1816ee0816b70ff
```

### 3. Flutter 配置

文件位置：`lib/firebase_options.dart`

已配置 Android、iOS、Web、macOS、Windows 平台的 Firebase 选项。

---

## 你需要在 Firebase Console 完成的配置

### 步骤 1：启用 Authentication

1. 打开 [Firebase Console](https://console.firebase.google.com/)
2. 选择项目 `xinsheng-app`
3. 左侧菜单 → **Authentication** → **开始使用**
4. 点击 **登录方法** 标签
5. 启用 **电子邮件/密码** → 保存

### 步骤 2：创建 Firestore Database

1. 左侧菜单 → **Firestore Database** → **创建数据库**
2. 选择 **测试模式**
3. 选择数据中心（推荐 `asia-northeast1` 东京）
4. 点击 **启用**
5. 点击 **规则** 标签，粘贴以下安全规则：

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

6. 点击 **发布**

### 步骤 3：启用 Storage

1. 左侧菜单 → **Storage** → **开始使用**
2. 选择 **测试模式**
3. 选择数据中心
4. 点击 **完成**
5. 点击 **规则** 标签，粘贴以下安全规则：

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

6. 点击 **发布**

### 步骤 4：配置 Cloud Messaging（可选）

**Android 推送**：已自动配置，无需操作。

**iOS 推送**（需要 Apple Developer 账号）：
1. 登录 [Apple Developer](https://developer.apple.com/)
2. 创建 APNs 认证密钥
3. 在 Firebase Console → 项目设置 → Cloud Messaging 中上传密钥

---

## 运行 APP

完成 Firebase Console 配置后：

```bash
cd /mnt/okcomputer/output/xinsheng_app

# 安装依赖
flutter pub get

# 运行 APP
flutter run
```

---

## 项目结构

```
xinsheng_app/
├── android/
│   ├── app/
│   │   ├── build.gradle          ✅ 已配置
│   │   ├── google-services.json  ✅ 已配置
│   │   └── src/main/
│   │       ├── AndroidManifest.xml ✅ 已配置
│   │       └── kotlin/.../MainActivity.kt ✅ 已配置
│   ├── build.gradle              ✅ 已配置
│   └── settings.gradle           ✅ 已配置
├── ios/
│   ├── Runner/
│   │   ├── AppDelegate.swift     ✅ 已配置
│   │   ├── GoogleService-Info.plist ✅ 已配置
│   │   └── Info.plist            ✅ 已配置
│   ├── Runner.xcworkspace/       ✅ 已配置
│   └── Podfile                   ✅ 已配置
├── lib/
│   ├── firebase_options.dart     ✅ 已配置
│   └── ... (其他代码)
├── pubspec.yaml                  ✅ 已配置
└── README.md
```

---

## 常见问题

### Q: 运行时报 "Firebase not configured"？
**A:** 检查配置文件是否在正确位置，并重新运行 `flutter clean && flutter pub get`

### Q: 注册/登录失败？
**A:** 检查 Firebase Console 中 Authentication 是否启用了"电子邮件/密码"

### Q: 无法发布笔记或上传图片？
**A:** 检查 Firestore 和 Storage 的安全规则是否正确配置

---

## 参考文档

- [Firebase 官方文档](https://firebase.google.com/docs)
- [FlutterFire 文档](https://firebase.flutter.dev/)
