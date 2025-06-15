# 外观管理系统使用指南

## 概述

本指南介绍了 encodify 应用中现代化的外观管理系统的使用方法。该系统包含以下几个核心组件：

- **AppearanceManager**: 全局外观配置管理器
- **ThemeManager**: 主题和深色模式管理器
- **ButtonStyler**: 按钮样式配置器
- **CardStyler**: 卡片样式配置器
- **TextStyler**: 文本样式配置器
- **LayoutHelper**: 布局辅助工具
- **AnimationHelper**: 动画辅助工具
- **ResponsiveDesignHelper**: 响应式设计工具

## 基本用法

### 1. 按钮样式

```swift
// 创建主要按钮
let primaryButton = UIButton()
primaryButton.applyStyle(.primary, size: .large, title: "确认")

// 创建次要按钮
let secondaryButton = UIButton()
secondaryButton.applyStyle(.secondary, size: .medium, title: "取消")

// 创建危险操作按钮
let deleteButton = UIButton()
deleteButton.applyStyle(.destructive, size: .medium, title: "删除")
```

### 2. 卡片样式

```swift
// 创建内容卡片
let contentView = UIView()
contentView.applyContentCardStyle()

// 创建列表项卡片
let listItemView = UIView()
listItemView.applyListItemCardStyle()

// 创建输入框卡片
let inputContainerView = UIView()
inputContainerView.applyInputCardStyle()

// 自定义卡片样式
let customView = UIView()
customView.applyCardStyle(
    .elevated,
    cornerRadius: .large,
    elevation: .medium,
    backgroundColor: UIColor.encodifyCardBackground
)
```

### 3. 文本样式

```swift
// 设置标题文字
let titleLabel = UILabel()
titleLabel.setText("主标题", style: .largeTitle)

// 设置正文文字
let bodyLabel = UILabel()
bodyLabel.setText("这是正文内容", style: .body)

// 设置说明文字
let captionLabel = UILabel()
captionLabel.setText("说明文字", style: .caption1)

// 设置按钮文字
let button = UIButton()
button.setTitle("按钮文字", style: .buttonText)

// 配置文本框
let textField = UITextField()
textField.configurePlaceholder("请输入内容", style: .inputText)
```

### 4. 布局工具

```swift
// 使用标准间距
let spacing = LayoutHelper.Spacing.medium.adaptive

// 创建垂直堆栈
let stackView = LayoutHelper.verticalStack(
    views: [titleLabel, bodyLabel, button],
    spacing: .medium,
    alignment: .fill
)

// 约束到安全区域
view.addSubview(stackView)
stackView.fillSafeArea(insets: .all(.large))

// 设置固定尺寸
button.constrainHeight(50)

// 居中显示
loadingView.centerInSuperview()
```

### 5. 动画效果

```swift
// 淡入动画
newView.fadeIn(preset: .gentle) {
    print("动画完成")
}

// 弹入效果
cardView.popIn(preset: .bouncy)

// 滑动效果
sideMenuView.slideIn(direction: .left, preset: .smooth)

// 按钮交互动画
button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
// 动画会自动处理

// 顺序动画
AnimationHelper.staggeredAnimation(
    views: [card1, card2, card3],
    animation: { view, delay, completion in
        view.popIn(preset: .gentle, delay: delay, completion: completion)
    },
    stagger: 0.1
)
```

### 6. 响应式设计

```swift
// 获取响应式字体
let adaptiveFont = UIFont.responsive(baseSize: 17, weight: .medium)

// 响应式间距
let adaptiveSpacing = CGFloat(16).responsive()

// 响应式圆角
let adaptiveCornerRadius = CGFloat(12).responsiveCornerRadius()

// 获取推荐列数
let columns = ResponsiveDesignHelper.recommendedColumns(
    minItemWidth: 200,
    spacing: 16,
    margins: 32
)

// 获取设备信息
let deviceInfo = ResponsiveDesignHelper.deviceInfo
if deviceInfo.category.isPad {
    // 平板特定处理
}
```

### 7. 主题管理

```swift
// 获取当前主题
let currentTheme = ThemeManager.shared.currentTheme

// 切换主题
ThemeManager.shared.setTheme(.dark)

// 获取主题颜色
let colors = ThemeManager.shared.getCurrentThemeColors()
view.backgroundColor = colors.primaryBackground

// 创建主题感知的视图
class MyCustomView: ThemeAwareView {
    override func applyTheme() {
        super.applyTheme()
        let colors = ThemeManager.shared.getCurrentThemeColors()
        titleLabel.textColor = colors.primaryText
        subtitleLabel.textColor = colors.secondaryText
    }
}

// 应用主题感知的阴影
cardView.applyThemeAwareShadow(radius: 8, opacity: 0.15)
```

## 高级用法

### 1. 自定义样式预设

```swift
// 扩展 ButtonStyler 添加自定义样式
extension ButtonStyler {
    static func configureCallToActionButton(_ button: UIButton) {
        configure(button, style: .primary, size: .large)
        button.layer.shadowColor = UIColor.encodifyTintColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.3
    }
}
```

### 2. 创建复合组件

```swift
class EncodifyCard: ThemeAwareView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton()
    
    override func applyTheme() {
        super.applyTheme()
        
        // 应用卡片样式
        self.applyContentCardStyle()
        
        // 配置文本样式
        titleLabel.setText("", style: .cardTitle)
        subtitleLabel.setText("", style: .cardSubtitle)
        actionButton.applyStyle(.primary, size: .medium)
        
        // 创建布局
        let stackView = LayoutHelper.verticalStack(
            views: [titleLabel, subtitleLabel, actionButton],
            spacing: .medium
        )
        
        addSubview(stackView)
        stackView.fillSuperview(insets: .all(.large))
    }
}
```

### 3. 响应式网格布局

```swift
class ResponsiveGridView: ThemeAwareView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let columns = ResponsiveDesignHelper.recommendedColumns(
            minItemWidth: 150,
            spacing: 16,
            margins: 32
        )
        
        // 重新计算网格布局
        updateGridLayout(columns: columns)
    }
}
```

## 最佳实践

### 1. 一致性原则
- 始终使用预定义的样式而不是硬编码值
- 使用 LayoutHelper.Spacing 枚举而不是原始数值
- 优先使用语义化的颜色名称

### 2. 响应式设计
- 考虑不同设备尺寸的适配
- 使用响应式字体和间距
- 测试横屏和竖屏模式

### 3. 无障碍支持
- 确保最小触摸目标为 44pt
- 使用语义化的颜色
- 支持动态字体大小

### 4. 性能优化
- 避免在主线程执行复杂的样式计算
- 使用阴影路径优化阴影渲染
- 合理使用动画，避免过度使用

### 5. 主题适配
- 继承 ThemeAwareView 或 ThemeAwareViewController
- 使用主题感知的颜色和图片
- 测试浅色和深色模式

## 注意事项

1. **性能考虑**: 大量视图同时使用复杂样式可能影响性能，建议适度使用
2. **设备兼容**: 部分样式在旧设备上可能表现不同，建议在目标设备上测试
3. **主题切换**: 主题切换会重新配置全局外观，可能导致短暂的视觉闪烁
4. **内存管理**: 注意移除主题观察者，避免内存泄漏

通过合理使用这些工具，可以创建出现代化、一致性强、用户体验优秀的 iOS 应用界面。
