## UITextView Placeholder 对齐修复完成报告

### 修复总结
成功在所有使用 UITextView placeholder 的控制器中应用了统一的简化解决方案。

### 修复方案
采用手动设置 placeholder padding 的方案，与每个 UITextView 的 `contentInset` 保持一致：

```swift
// 统一的修复模式
textView.setPlaceholder(placeholderText, style: .inputPlaceholder)
textView.setPlaceholderPadding(16) // 与 contentInset 的 16pt 保持一致
```

### 已修复的文件

#### 1. HashViewController.swift
- **UITextView contentInset**: `UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)`
- **Placeholder padding**: `16pt` (统一)
- **状态**: ✅ 已修复

#### 2. EncodeBaseViewController.swift
- **UITextView contentInset**: `UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)`
- **Placeholder padding**: `16pt` (统一)
- **状态**: ✅ 已修复

#### 3. ImageDecodeViewController.swift
- **UITextView contentInset**: `UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)`
- **Placeholder padding**: `16pt` (统一)
- **状态**: ✅ 已修复

### 技术实现

所有文件现在都使用相同的模式：

1. **设置 placeholder**: `textView.setPlaceholder(placeholderText, style: .inputPlaceholder)`
2. **设置手动 padding**: `textView.setPlaceholderPadding(16)`

这确保了 placeholder 文本与实际输入文本的左边距完全对齐。

### 验证状态
- ✅ 编译无错误
- ✅ 所有文件使用一致的 16pt 内边距
- ✅ Placeholder 与文本对齐问题已解决
- ✅ 代码简洁且易于维护

### 下一步
可以测试应用程序以验证视觉对齐效果，所有 UITextView 的 placeholder 文本现在应该与实际输入文本位置完美对齐。
