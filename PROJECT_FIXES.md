# 心声 APP - 项目修复记录

## 修复日期
2026-02-14

## 修复内容

### 1. Android Gradle 配置修复

#### 问题
- 缺少 `gradle-wrapper.properties` 文件
- `settings.gradle` 配置不兼容 Codemagic
- `animations` 版本不兼容 Flutter 3.27+

#### 修复
1. **创建 `android/gradle/wrapper/gradle-wrapper.properties`**
   - Gradle 版本: 8.2
   - 下载地址: https://services.gradle.org/distributions/gradle-8.2-all.zip

2. **更新 `android/settings.gradle`**
   - 添加 Flutter SDK 自动检测逻辑
   - 支持环境变量 `FLUTTER_ROOT`
   - 支持常见安装路径自动查找

3. **更新 `android/build.gradle`**
   - 简化配置，移除重复依赖

4. **更新 `android/app/build.gradle`**
   - 使用 `compileSdk` 替代 `compileSdkVersion`
   - 使用 `minSdk` 替代 `minSdkVersion`
   - 使用 `targetSdk` 替代 `targetSdkVersion`

5. **更新 `pubspec.yaml`**
   - `animations`: `^3.0.0` → `^2.0.11` (兼容 Flutter 3.x)

### 2. iOS 配置修复

#### 修复
1. **更新 `ios/Podfile`**
   - 移除硬编码 Firebase pods（通过 FlutterFire 自动管理）
   - 保持 iOS 13.0 最低版本
   - 禁用 Bitcode

2. **保留 `ios/Runner/AppDelegate.swift`**
   - Firebase 配置正确
   - 推送通知配置正确

### 3. Codemagic 配置

#### 新增 `codemagic.yaml`
- Android 工作流: 构建 release APK
- iOS 工作流: 构建 release app (无签名)

## 文件变更清单

### 新增文件
- `android/gradle/wrapper/gradle-wrapper.properties`
- `codemagic.yaml`

### 修改文件
- `android/settings.gradle`
- `android/build.gradle`
- `android/app/build.gradle`
- `ios/Podfile`
- `pubspec.yaml`

## 打包测试

### Codemagic 打包步骤

1. **上传代码到 GitHub**
   ```bash
   cd ~/Downloads/xinsheng_app
   git init
   git add .
   git commit -m "Fix Gradle and iOS config for Codemagic"
   git remote add origin https://github.com/YOUR_USERNAME/xinsheng-app.git
   git push -u origin main
   ```

2. **在 Codemagic 配置**
   - 登录 https://codemagic.io
   - 添加应用，选择 GitHub 仓库
   - 选择 workflow: Android Build 或 iOS Build
   - 点击 Start build

3. **等待打包完成**
   - Android: 约 10-15 分钟
   - iOS: 约 15-20 分钟

4. **下载 APK/IPA**
   - 从 Artifacts 下载

## 注意事项

### Android
- 确保 `google-services.json` 在 `android/app/` 目录
- Firebase 项目包名: `com.xinsheng.xinsheng`

### iOS
- 确保 `GoogleService-Info.plist` 在 `ios/Runner/` 目录
- Bundle ID: `com.xinsheng.xinsheng`
- iOS 打包需要签名证书才能安装到真机

## 依赖版本

| 包名 | 版本 | 说明 |
|------|------|------|
| firebase_core | ^2.24.2 | Firebase 核心 |
| firebase_auth | ^4.16.0 | 认证 |
| cloud_firestore | ^4.14.0 | 数据库 |
| firebase_messaging | ^14.7.10 | 推送 |
| flutter_riverpod | ^2.4.9 | 状态管理 |
| go_router | ^13.0.1 | 路由 |
| animations | ^2.0.11 | 动画 (兼容版) |

## 已知问题

### iOS 打包限制
- Codemagic iOS 工作流构建的是未签名版本
- 要安装到真机需要:
  - Apple Developer 账号 ($99/年)
  - 配置签名证书
  - 或使用 TestFlight

## 联系支持

如果打包仍有问题，请提供:
1. 完整的错误日志
2. Codemagic build URL
3. 截图
