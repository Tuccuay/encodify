# 📱 Encodify iOS App

一个功能强大的编码解码工具应用，支持多种编码格式和哈希算法。

## 📲 立即下载

[**在 App Store 下载 Encodify**](https://apps.apple.com/app/id1074602693)

## 🎉 Swift迁移完成

本项目已成功从Objective-C完全迁移到Swift，支持最新的iOS特性和现代开发实践。

## 📚 完整文档

> 📋 **所有项目文档已整理到 [docs/](./docs/) 文件夹**

### 🚀 快速导航

- **[📖 完整文档索引](./docs/INDEX.md)** - 查看所有技术文档
- **[🚀 快速入门指南](./docs/QUICK_START.md)** - 用户和开发者快速开始
- **[📲 应用下载信息](./docs/DOWNLOAD.md)** - App Store下载详情
- **[📋 项目概览](./docs/PROJECT_OVERVIEW.md)** - 完整项目概览
- **[🎉 迁移完成报告](./docs/FINAL_COMPLETION_REPORT.md)** - 项目完成状态

### 👨‍💻 开发者资源

- **[🏗️ 架构说明](./docs/APPDELEGATE_SCENEDELEGATE_EXPLANATION.md)** - 现代iOS应用架构
- **[🔄 迁移指南](./docs/SWIFT_MIGRATION.md)** - Objective-C到Swift迁移
- **[🛠️ 构建脚本](./scripts/README.md)** - 开发工具和自动化脚本

## ✨ 主要功能

### 📝 编码解码
- **摩斯码**: 支持英文和中文字符
- **Base64**: 标准Base64编码解码  
- **URL编码**: URL安全的编码解码
- **Unicode**: Unicode字符编码

### 🔐 哈希计算
- MD5, SHA1, SHA224, SHA256, SHA384, SHA512
- 支持文本输入的多种哈希算法计算

### 🖼️ 图片处理
- 图片编码为Base64
- Base64解码为图片
- 支持多种图片格式

## 🛠️ 技术栈

- **语言**: Swift 5.9+
- **最低支持**: iOS 15.6+
- **架构**: AppDelegate + SceneDelegate (支持iOS 13+多场景)
- **依赖管理**: CocoaPods

### 📦 主要依赖
- **CryptoSwift**: 加密和哈希算法
- **NotificationBannerSwift**: 现代化通知组件
- **SnapKit**: 自动布局框架
- **XLPagerTabStrip**: 页面切换组件

## 🚀 快速开始

### 📱 用户
直接从 [App Store 下载](https://apps.apple.com/app/id1074602693) 即可使用。

### 👨‍💻 开发者
```bash
# 1. 克隆项目
git clone https://github.com/tuccuay/encodify.git

# 2. 安装依赖
pod install

# 3. 打开项目
open encodify.xcworkspace
```

详细开发指南请查看 **[快速入门文档](./docs/QUICK_START.md)**

## 📊 项目状态

✅ **迁移完成度**: 100%  
✅ **Swift文件数**: 20个  
✅ **功能覆盖率**: 100%  
✅ **文档完备性**: 优秀  

## 🌟 项目亮点

- **100% Swift化** - 完全现代化的代码库
- **中文摩斯码** - 独特的Unicode字符支持
- **主线程安全** - 符合Swift并发编程最佳实践
- **完整文档** - 详尽的技术文档和迁移记录

## 🤝 贡献

欢迎提交Issues和Pull Requests来改进这个项目！

详细贡献指南请参考 [项目文档](./docs/INDEX.md)。

## 📄 许可证

本项目采用 [MIT License](./LICENSE)。

## 🎯 版本信息

- **当前版本**: 3.1.2 (Build 71)
- **Swift版本**: 5.9+
- **iOS支持**: 15.6+
- **最后更新**: 2025年6月12日

---

**Encodify** - 让编码解码变得简单而强大 🚀
