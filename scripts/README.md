# 🛠️ Encodify 脚本和工具

本文件夹包含用于构建、测试和维护Encodify项目的各种脚本和工具。

## 📋 脚本概览

### 🚀 构建和部署
- **[build_test.sh](./build_test.sh)** - 自动化构建测试脚本
  - Pod依赖安装
  - Xcode项目构建验证
  - 错误检测和报告

- **[.travis.yml](./.travis.yml)** - Travis CI持续集成配置
  - 自动化构建流程
  - 多环境测试支持
  - 代码质量检查

### ✅ 验证和测试
- **[verify_migration.sh](./verify_migration.sh)** - 迁移状态验证脚本
  - Swift文件完整性检查
  - 依赖关系验证
  - 项目结构分析

### 🧪 功能测试
- **[test_morse.swift](./test_morse.swift)** - 摩斯码编码器测试
  - 英文摩斯码编解码测试
  - 中文Unicode摩斯码测试
  - 混合文本处理验证

- **[test_hash.swift](./test_hash.swift)** - 哈希计算器测试
  - 多种哈希算法验证
  - CryptoSwift库兼容性测试
  - 性能基准测试

## 🔧 使用说明

### 构建项目
```bash
# 运行完整构建测试
./scripts/build_test.sh

# 仅安装依赖
pod install

# 清理并重新构建
xcodebuild clean build -workspace encodify.xcworkspace -scheme encodify
```

### 验证迁移状态
```bash
# 检查Swift迁移完整性
./scripts/verify_migration.sh

# 检查特定功能
swift scripts/test_morse.swift
swift scripts/test_hash.swift
```

### CI/CD支持
```bash
# 本地模拟Travis CI构建
# 参考 .travis.yml 配置
xcodebuild clean build -sdk iphonesimulator \
  -workspace encodify.xcworkspace \
  -scheme encodify \
  CODE_SIGNING_REQUIRED=NO
```

## 📊 脚本功能矩阵

| 脚本 | 构建 | 测试 | 验证 | CI/CD |
|------|------|------|------|-------|
| build_test.sh | ✅ | ✅ | ⭕ | ⭕ |
| verify_migration.sh | ⭕ | ⭕ | ✅ | ⭕ |
| test_morse.swift | ⭕ | ✅ | ⭕ | ⭕ |
| test_hash.swift | ⭕ | ✅ | ⭕ | ⭕ |

图例: ✅ 主要功能 | ⭕ 支持功能

## 🎯 最佳实践

### 开发流程
1. **开发前**: 运行 `verify_migration.sh` 检查项目状态
2. **功能开发**: 使用对应的测试脚本验证功能
3. **提交前**: 运行 `build_test.sh` 确保构建正常
4. **发布前**: 执行所有测试脚本进行完整验证

### 错误排查
```bash
# 构建失败时
./scripts/build_test.sh --verbose

# 功能异常时
swift scripts/test_morse.swift
swift scripts/test_hash.swift

# 依赖问题时
pod install --verbose
./scripts/verify_migration.sh
```

## 🔍 脚本维护

### 版本要求
- **Shell**: Bash 4.0+ / Zsh 5.0+
- **Swift**: 5.9+
- **Xcode**: 15.0+
- **CocoaPods**: 1.12+

### 权限设置
```bash
# 给脚本添加执行权限
chmod +x scripts/*.sh

# 验证权限
ls -la scripts/
```

### 自定义配置
脚本支持通过环境变量进行自定义：
```bash
# 设置构建配置
export BUILD_CONFIGURATION=Release
export TARGET_SDK=iphoneos

# 设置测试参数
export TEST_VERBOSE=1
export TEST_OUTPUT_PATH=./test_results
```

## 🚀 未来扩展

### 计划添加的脚本
- **性能测试脚本**: 自动化性能基准测试
- **代码质量检查**: SwiftLint集成和代码分析
- **自动化发布**: App Store Connect上传脚本
- **本地化验证**: 多语言支持验证脚本

### CI/CD增强
- GitHub Actions工作流
- 自动化测试覆盖率报告
- 安全扫描集成
- 依赖更新通知

---

**最后更新**: 2025年6月12日  
**脚本版本**: Swift迁移完成版

需要帮助？查看各个脚本的内联注释或参考项目文档。
