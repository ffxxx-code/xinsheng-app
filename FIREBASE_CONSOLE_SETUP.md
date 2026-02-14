# Firebase Console 配置指南

> 完成本配置后，APP 的所有功能将正常工作

---

## 配置清单

- [ ] 1. 启用 Authentication（用户登录）
- [ ] 2. 创建 Firestore Database（数据存储）
- [ ] 3. 启用 Storage（图片存储）
- [ ] 4. 配置 Cloud Messaging（推送通知）

---

## 第一步：启用 Authentication（2分钟）

### 操作步骤：

1. 打开 [Firebase Console](https://console.firebase.google.com/)
2. 选择你的项目 `xinsheng-app`
3. 左侧菜单点击 **Authentication** → **开始使用**
4. 点击 **登录方法** 标签
5. 找到 **电子邮件/密码**，点击启用
6. 开启第一个开关（电子邮件/密码），保存

### 预期结果：
```
✅ 用户可以使用邮箱和密码注册/登录
```

---

## 第二步：创建 Firestore Database（3分钟）

### 操作步骤：

1. 左侧菜单点击 **Firestore Database** → **创建数据库**
2. 选择 **测试模式**（开始开发用，后续可改生产模式）
3. 选择数据中心（推荐选 `asia-northeast1` 东京，离中国近）
4. 点击 **启用**

### 配置安全规则（重要！）：

数据库创建后，点击 **规则** 标签，替换为以下代码：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用户数据规则
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 笔记数据规则
    match /notes/{noteId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
    
    // 评论数据规则
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
    
    // 消息数据规则
    match /messages/{messageId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.senderId || request.auth.uid == resource.data.receiverId);
      allow create: if request.auth != null && request.auth.uid == request.resource.data.senderId;
    }
    
    // 通知数据规则
    match /notifications/{notificationId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create, update: if request.auth != null;
    }
    
    // 聊天室规则
    match /chatRooms/{chatRoomId} {
      allow read: if request.auth != null && request.auth.uid in resource.data.participants;
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid in resource.data.participants;
    }
  }
}
```

点击 **发布**

### 预期结果：
```
✅ 用户数据、笔记、评论可以正常读写
```

---

## 第三步：启用 Storage（2分钟）

### 操作步骤：

1. 左侧菜单点击 **Storage** → **开始使用**
2. 选择 **测试模式**（开始开发用）
3. 选择数据中心（建议和 Firestore 相同）
4. 点击 **完成**

### 配置安全规则（重要！）：

点击 **规则** 标签，替换为以下代码：

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // 用户头像
    match /avatars/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 笔记图片
    match /notes/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 聊天图片
    match /chat/{chatRoomId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

点击 **发布**

### 预期结果：
```
✅ 用户可以上传头像和笔记图片
```

---

## 第四步：配置 Cloud Messaging（3分钟）

### Android 推送（自动完成）

Android 推送已经自动配置好，无需额外操作。

### iOS 推送（需要额外配置）

**如果你只在 Android 上测试，可以跳过此步骤。**

#### 需要准备的：
- Apple Developer 账号（$99/年）
- 生成 APNs 密钥

#### 操作步骤：

1. 登录 [Apple Developer](https://developer.apple.com/)
2. 进入 **Certificates, Identifiers & Profiles**
3. 点击 **Keys** → **+** 创建新密钥
4. 名称填 `Firebase Cloud Messaging`
5. 勾选 **Apple Push Notifications service (APNs)**
6. 点击 **Continue** → **Register** → **Download**
7. 保存好下载的 `.p8` 文件和 Key ID

8. 回到 Firebase Console，左侧菜单点击 **项目设置**（齿轮图标）
9. 点击 **Cloud Messaging** 标签
10. 找到 **iOS 应用配置** 下的 **APNs 认证密钥**
11. 点击 **上传**，选择刚才下载的 `.p8` 文件
12. 输入 Key ID 和 Team ID（在 Apple Developer 的 Membership 页面查看）
13. 点击 **上传**

### 预期结果：
```
✅ Android 推送：立即可用
✅ iOS 推送：配置 APNs 后可用
```

---

## 验证配置是否成功

完成以上配置后，运行以下命令测试：

```bash
cd /mnt/okcomputer/output/xinsheng_app
flutter pub get
flutter run
```

### 测试清单：

- [ ] APP 能正常启动无报错
- [ ] 能注册新账号
- [ ] 能登录已有账号
- [ ] 能发布笔记
- [ ] 能上传图片
- [ ] 能收到推送通知（需要真机测试）

---

## 常见问题

### Q1: 运行时报 "Firebase not configured" 错误？
**A:** 检查 `google-services.json` 和 `GoogleService-Info.plist` 是否在正确位置。

### Q2: 注册/登录失败？
**A:** 检查 Authentication 是否启用了"电子邮件/密码"登录方式。

### Q3: 无法发布笔记？
**A:** 检查 Firestore 安全规则是否正确配置。

### Q4: 无法上传图片？
**A:** 检查 Storage 安全规则是否正确配置。

---

## 下一步

配置完成后，你就可以：
1. 在模拟器/真机上运行 APP
2. 注册账号开始使用
3. 发布笔记、评论、私信等功能

**遇到问题随时问我！**
