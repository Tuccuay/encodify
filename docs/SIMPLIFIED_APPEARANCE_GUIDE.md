# 简化外观管理系统使用指南

## 概述

经过重构，Encodify 应用的外观管理系统现在完全跟随系统设置，不再提供自定义主题切换功能。这样设计的优势：

1. **系统一致性**: 完全遵循 iOS 系统的外观设置
2. **更好的用户体验**: 用户在系统设置中的偏好会自动反映在应用中
3. **并发安全**: 所有UI相关操作都标记为 @MainActor
4. **简化维护**: 减少了复杂的主题管理代码

## 核心变更

### 1. ThemeManager 简化

```swift
// 现在只跟随系统设置
let isDarkMode = ThemeManager.shared.isDarkMode  // 跟随系统深色模式
let colors = ThemeManager.shared.getCurrentThemeColors()  // 获取系统主题颜色
```

### 2. 动态字体支持

系统会自动响应用户在"设置 > 显示与亮度 > 文字大小"中的更改：

```swift
// 字体会自动适配系统设置
label.setText("标题", style: .headline)  // 自动支持动态字体
```

### 3. 深色模式支持

应用会自动跟随系统的深色模式设置：

```swift
// 创建主题感知的视图
class MyView: ThemeAwareView {
    override func applyTheme() {
        super.applyTheme()
        // 这里的代码会在系统主题变化时自动调用
        let colors = ThemeManager.shared.getCurrentThemeColors()
        titleLabel.textColor = colors.primaryText
    }
}
```

## 基本用法

### 1. 按钮样式（保持不变）

```swift
let primaryButton = UIButton()
primaryButton.applyStyle(.primary, size: .large, title: "确认")
```

### 2. 卡片样式（保持不变）

```swift
let contentView = UIView()
contentView.applyContentCardStyle()
```

### 3. 文本样式（保持不变）

```swift
let titleLabel = UILabel()
titleLabel.setText("主标题", style: .largeTitle)
```

### 4. 主题感知组件

```swift
// 继承主题感知基类
class MyCustomView: ThemeAwareView {
    override func applyTheme() {
        super.applyTheme()
        // 系统主题变化时会自动调用
        let colors = ThemeManager.shared.getCurrentThemeColors()
        // 应用主题相关的样式
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // 系统会自动处理主题和字体大小变化
    }
}
```

## 系统响应

### 1. 深色模式切换

当用户在控制中心或设置中切换深色模式时：
- 所有 `ThemeAwareView` 和 `ThemeAwareViewController` 会自动更新
- 颜色会自动适配新的主题
- 状态栏样式会自动调整

### 2. 动态字体调整

当用户调整系统字体大小时：
- 所有使用 `TextStyler` 配置的文本会自动缩放
- 布局会自动适配新的字体大小
- 不需要重启应用

### 3. 无障碍功能

系统会自动响应以下无障碍设置：
- 增强对比度
- 减少透明度
- 动态字体大小
- 减少动画

## 并发安全性

所有UI相关的操作现在都标记为 `@MainActor`：

```swift
@MainActor
class AppearanceManager {
    static let shared = AppearanceManager()
    // 所有方法都在主线程执行
}

@MainActor 
struct ButtonStyler {
    // 所有样式配置都在主线程执行
}
```

## 最佳实践

### 1. 使用系统颜色

```swift
// 推荐：使用语义化的系统颜色
view.backgroundColor = UIColor.systemBackground
label.textColor = UIColor.label

// 推荐：使用应用定义的语义颜色
view.backgroundColor = UIColor.encodifyCardBackground
label.textColor = UIColor.encodifyPrimaryText
```

### 2. 响应主题变化

```swift
class MyViewController: ThemeAwareViewController {
    override func applyTheme() {
        super.applyTheme()
        
        // 更新自定义UI元素
        updateCustomUI()
    }
    
    private func updateCustomUI() {
        let colors = ThemeManager.shared.getCurrentThemeColors()
        customView.backgroundColor = colors.cardBackground
    }
}
```

### 3. 支持动态字体

```swift
// 使用 TextStyler 自动支持动态字体
titleLabel.setText("标题", style: .headline)

// 自定义字体也要支持动态缩放
let customFont = UIFont.systemFont(ofSize: 17, weight: .medium)
let scaledFont = UIFontMetrics.default.scaledFont(for: customFont)
label.font = scaledFont
label.adjustsFontForContentSizeCategory = true
```

## 注意事项

1. **不要覆盖系统主题**: 应用不再提供自定义主题切换，完全跟随系统
2. **测试不同系统设置**: 确保在各种系统设置下都能正常工作
3. **使用语义化颜色**: 避免硬编码颜色值，使用系统提供的语义化颜色
4. **支持动态字体**: 确保所有文本都能响应系统字体大小设置

通过这种简化的设计，应用的外观管理变得更加稳定、一致和易于维护。
