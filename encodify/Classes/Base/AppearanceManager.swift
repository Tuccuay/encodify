//
//  AppearanceManager.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 管理应用全局外观配置的单例类
/// 
/// 设计原则 (iOS 16.6+):
/// - 品牌一致性：使用 encodifyTintColor 作为主色调
/// - 系统一致性：保持与系统 UI 的融合
/// - 自动适配：支持深色模式、动态字体、无障碍功能
/// - 现代化设计：遵循 iOS 16.6+ 人机界面指南
/// 
/// 这种方法确保应用具有统一的品牌视觉风格，同时保持系统一致性
@MainActor
final class AppearanceManager {
    
    // MARK: - Singleton
    
    static let shared = AppearanceManager()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 配置应用的整体外观
    func configureAppearance() {
        configureNavigationBarAppearance()
        configureTabBarAppearance()
        configureControlAppearance()
        configureButtonAppearance()
        configureTextFieldAppearance()
        configureTableViewAppearance()
        configureCollectionViewAppearance()
        configureScrollViewAppearance()
        configureToolbarAppearance()
        configurePickerAppearance()
        configureIndicatorAppearance()
        configureLabelAppearance()
        configurePopoverAppearance()
        configureAlertAndActionSheetAppearance()
        configureSystemIntegration()
    }
    
    // MARK: - Navigation Bar Configuration
    
    private func configureNavigationBarAppearance() {
        
        let navigationBarAppearance = UINavigationBar.appearance()

        // 保持品牌一致的 tintColor
        navigationBarAppearance.tintColor = UIColor.encodifyTintColor
    }
    
    // MARK: - Tab Bar Configuration
    
    private func configureTabBarAppearance() {
        
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = .encodifyTintColor
    }
    
    // MARK: - Control Configuration
    
    private func configureControlAppearance() {
        // 品牌一致的控件配置
        
        // 设置全局 tintColor 为品牌主色调
        UIView.appearance().tintColor = UIColor.encodifyTintColor
        
        // 开关控件 - 品牌风格
        UISwitch.appearance().onTintColor = UIColor.encodifyTintColor
        UISwitch.appearance().thumbTintColor = UIColor.white
        
        // 步进器控件 - 品牌风格
        UIStepper.appearance().tintColor = UIColor.encodifyTintColor
        
        // 滑块控件 - 品牌风格
        UISlider.appearance().tintColor = UIColor.encodifyTintColor
        UISlider.appearance().thumbTintColor = UIColor.encodifyTintColor
        UISlider.appearance().minimumTrackTintColor = UIColor.encodifyTintColor
        UISlider.appearance().maximumTrackTintColor = UIColor.systemGray4
        
        // 进度条 - 品牌风格
        UIProgressView.appearance().tintColor = UIColor.encodifyTintColor
        UIProgressView.appearance().trackTintColor = UIColor.systemGray5
        
        // 分段控件 - 品牌风格
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.encodifyTintColor
        UISegmentedControl.appearance().backgroundColor = UIColor.systemGray6
    }
    
    // MARK: - Button Configuration
    
    private func configureButtonAppearance() {
        // iOS 16.6+ 品牌风格按钮配置
        
        // 设置按钮的品牌风格 tintColor
        UIButton.appearance().tintColor = UIColor.encodifyTintColor
        
        // 保持系统默认的背景和字体，仅调整颜色
        // 这确保了品牌一致性的视觉风格
        
        // 对于需要特殊样式的按钮，建议在具体实现中使用 UIButton.Configuration
        // 并应用品牌风格的颜色主题
        configureBrandButtonStyles()
    }
    
    /// 配置品牌风格按钮样式指南
    private func configureBrandButtonStyles() {
        // 品牌按钮样式特点：
        // - 主要操作：encodifyTintColor 背景，白色文字
        // - 次要操作：encodifyTintColor 文字，透明背景
        // - 取消操作：systemGray 文字，透明背景
        
        // 推荐在具体实现中使用以下配置：
        // 主要按钮：UIButton.Configuration.filled() + encodifyTintColor 背景
        // 次要按钮：UIButton.Configuration.plain() + encodifyTintColor 文字
        // 取消按钮：UIButton.Configuration.plain() + systemGray 文字
    }
    
    // MARK: - System Integration
    
    private func configureSystemIntegration() {
        // 配置现代化 iOS 16.6+ 系统集成
        configureDynamicTypeSupport()
        configureAccessibilitySupport()
        
        // 配置现代化系统特性
        configureModernSystemFeatures()
    }
    
    /// 配置现代化系统特性 (iOS 16.6+)
    private func configureModernSystemFeatures() {
        // 启用自动外观更新
        if #available(iOS 17.0, *) {
            // iOS 17+ 特性：可以在这里添加更新的 API
            // 例如：新的动画效果、交互特性等
        }
        
        // 确保支持现代设备特性
        configureModernDeviceSupport()
        
        // 配置现代化触觉反馈
        configureModernHapticFeedback()
        
        // 配置现代化动画支持
        configureModernAnimationSupport()
    }
    
    /// 配置现代设备支持
    private func configureModernDeviceSupport() {
        // 为不同设备尺寸优化外观
        // - iPhone 14 Pro/Pro Max 动态岛支持
        // - 自适应布局支持
        // - 安全区域自动处理
        
        // 使用系统默认的安全区域处理
        // 让系统自动处理状态栏、动态岛和主屏指示器区域
        
        // 支持所有屏幕尺寸的自适应设计
        configureAdaptiveLayoutSupport()
    }
    
    /// 配置自适应布局支持
    private func configureAdaptiveLayoutSupport() {
        // 确保应用在所有设备上都有一致的体验
        // - 紧凑和常规尺寸类别
        // - 横屏和竖屏模式
        // - 多任务和分屏模式
        
        // 使用系统提供的尺寸类别来调整布局
        // 这将自动处理不同设备和方向的布局适配
    }
    
    /// 配置现代化触觉反馈
    private func configureModernHapticFeedback() {
        // iOS 16.6+ 触觉反馈最佳实践
        // 使用系统提供的 UIImpactFeedbackGenerator、UINotificationFeedbackGenerator
        // 和 UISelectionFeedbackGenerator 来提供适当的触觉反馈
        
        // 触觉反馈应该与用户操作相匹配：
        // - 轻微操作使用 .light 强度
        // - 标准操作使用 .medium 强度  
        // - 重要操作使用 .heavy 强度
    }
    
    /// 配置现代化动画支持
    private func configureModernAnimationSupport() {
        // 遵循系统动画时长和缓动曲线
        // 使用 UIView.animate 和 UIViewPropertyAnimator
        
        // 系统推荐的动画时长：
        // - 快速过渡：0.2 秒
        // - 标准过渡：0.3 秒
        // - 复杂过渡：0.5 秒
        
        // 使用系统缓动曲线以确保一致性
    }
    
    // MARK: - Text Field Configuration
    
    private func configureTextFieldAppearance() {
        // 品牌风格文本框样式
        UITextField.appearance().tintColor = UIColor.encodifyTintColor
        UITextField.appearance().textColor = UIColor.encodifyPrimaryText
        
        // 品牌风格文本视图样式
        UITextView.appearance().tintColor = UIColor.encodifyTintColor
        UITextView.appearance().textColor = UIColor.encodifyPrimaryText
        
        // 品牌风格搜索框样式
        UISearchBar.appearance().tintColor = UIColor.encodifyTintColor
    }
    
    // MARK: - Table View Configuration
    
    private func configureTableViewAppearance() {
        // 品牌风格表格视图样式
        UITableView.appearance().tintColor = UIColor.encodifyTintColor
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().separatorColor = UIColor.encodifyBorderColor
        UITableView.appearance().sectionIndexColor = UIColor.encodifyTintColor
        UITableView.appearance().sectionIndexBackgroundColor = UIColor.clear
        
        // 品牌风格表格单元格样式
        UITableViewCell.appearance().tintColor = UIColor.encodifyTintColor
        UITableViewCell.appearance().backgroundColor = UIColor.systemBackground
        // 保留无选择样式，这是现代设计模式
        UITableViewCell.appearance().selectionStyle = .none
    }
    
    // MARK: - Collection View Configuration
    
    private func configureCollectionViewAppearance() {
        // 品牌风格集合视图样式
        UICollectionView.appearance().backgroundColor = UIColor.systemBackground
        UICollectionView.appearance().tintColor = UIColor.encodifyTintColor
    }
    
    // MARK: - Scroll View Configuration
    
    private func configureScrollViewAppearance() {
        // 品牌风格滚动视图样式
        UIScrollView.appearance().indicatorStyle = .default
        
        // 品牌风格刷新控件样式
        UIRefreshControl.appearance().tintColor = UIColor.encodifyTintColor
    }
    
    // MARK: - Toolbar Configuration
    
    private func configureToolbarAppearance() {
        // 工具栏配置 - 与导航栏保持一致
        
        let toolbarAppearance = UIToolbar.appearance()
        
        // 品牌一致的 tintColor
        toolbarAppearance.tintColor = UIColor.encodifyTintColor
    }
    
    // MARK: - Picker Configuration
    
    private func configurePickerAppearance() {
        // 选择器控件配置
        UIPickerView.appearance().backgroundColor = UIColor.systemBackground
        UIPickerView.appearance().tintColor = UIColor.encodifyTintColor
        
        // 日期选择器配置
        UIDatePicker.appearance().tintColor = UIColor.encodifyTintColor
        UIDatePicker.appearance().backgroundColor = UIColor.systemBackground
        
        // 页面控制器配置
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemGray4
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.encodifyTintColor
        UIPageControl.appearance().backgroundColor = UIColor.clear
    }
    
    // MARK: - Indicator Configuration
    
    private func configureIndicatorAppearance() {
        // 活动指示器配置
        UIActivityIndicatorView.appearance().color = UIColor.encodifyTintColor
        
        // 加载进度指示器在不同尺寸下的配置
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).color = UIColor.encodifyTintColor
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [UIToolbar.self]).color = UIColor.encodifyTintColor
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [UITabBar.self]).color = UIColor.encodifyTintColor
    }
    
    // MARK: - Label Configuration
    
    private func configureLabelAppearance() {
        // 标签配置 - 品牌风格
        // 注意：通常不需要为 UILabel 设置全局外观，因为它们应该根据具体用途进行配置
        // 但我们可以设置一些通用的品牌颜色作为默认值
        
        // 为系统默认标签设置品牌主题色调（很少使用，但为了完整性）
        UILabel.appearance().tintColor = UIColor.encodifyTintColor
    }
    
    // MARK: - Popover Configuration
    
    private func configurePopoverAppearance() {
        // Popover 弹出框配置
        // UIPopoverPresentationController 主要通过其 popoverBackgroundViewClass 进行定制
        // 这里配置一些基本的颜色设置
        
        // 确保 Popover 内容与应用主题一致
        // 大部分外观会自动继承自其内容视图控制器
    }
    
    // MARK: - Alert and Action Sheet Configuration
    
    private func configureAlertAndActionSheetAppearance() {
        // iOS 16.6+ 警告框和操作表使用系统默认样式
        // UIAlertController 自动适配系统外观，无需手动配置
        
        // 确保警告框和操作表遵循系统设计规范：
        // - 自动支持深色模式
        // - 自动适配动态字体
        // - 自动处理无障碍功能
        // - 自动适配不同设备尺寸
        
        // 推荐在创建 UIAlertController 时使用系统默认样式
        configureModernAlertStyles()
    }
    
    /// 配置现代化警告框样式指南
    private func configureModernAlertStyles() {
        // 现代化警告框最佳实践：
        // 1. 使用描述性的标题和消息
        // 2. 使用系统推荐的按钮样式 (.default, .destructive, .cancel)
        // 3. 避免过多的操作选项（建议不超过3个）
        // 4. 确保操作的层次结构清晰
        
        // UIAlertController 会自动处理外观，无需手动配置 appearance
    }
}

// MARK: - Modern Configuration Helpers

extension AppearanceManager {
    
    /// 品牌按钮配置类型
    enum BrandButtonStyle {
        case primary    // 主要操作按钮
        case secondary  // 次要操作按钮
        case destructive // 删除/取消按钮
        case plain      // 普通文本按钮
    }
    
    /// 获取品牌风格的按钮配置 (iOS 15+)
    @available(iOS 15.0, *)
    static func brandButtonConfiguration(for style: BrandButtonStyle) -> UIButton.Configuration {
        var config: UIButton.Configuration
        
        switch style {
        case .primary:
            config = .filled()
            config.baseBackgroundColor = UIColor.encodifyTintColor
            config.baseForegroundColor = UIColor.white
        case .secondary:
            config = .tinted()
            config.baseBackgroundColor = UIColor.encodifyTintColor.withAlphaComponent(0.1)
            config.baseForegroundColor = UIColor.encodifyTintColor
        case .destructive:
            config = .plain()
            config.baseForegroundColor = UIColor.encodifyErrorColor
        case .plain:
            config = .plain()
            config.baseForegroundColor = UIColor.encodifyTintColor
        }
        
        return config
    }
    
    /// 获取系统推荐的动画时长
    static func systemAnimationDuration(for type: SystemAnimationType) -> TimeInterval {
        switch type {
        case .quick:
            return 0.2
        case .standard:
            return 0.3
        case .complex:
            return 0.5
        }
    }
    
    /// 系统动画类型
    enum SystemAnimationType {
        case quick      // 快速过渡
        case standard   // 标准过渡
        case complex    // 复杂过渡
    }
    
    /// 获取系统推荐的触觉反馈
    static func systemHapticFeedback(for type: SystemHapticType) -> UIImpactFeedbackGenerator {
        switch type {
        case .light:
            return UIImpactFeedbackGenerator(style: .light)
        case .medium:
            return UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            return UIImpactFeedbackGenerator(style: .heavy)
        }
    }
    
    /// 系统触觉反馈类型
    enum SystemHapticType {
        case light      // 轻微操作
        case medium     // 标准操作
        case heavy      // 重要操作
    }
}

// MARK: - Dynamic Type Support

extension AppearanceManager {
    
    /// 配置动态字体支持
    func configureDynamicTypeSupport() {
        // 监听字体大小变化通知
        NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleContentSizeCategoryChange()
            }
        }
    }
    
    @MainActor
    private func handleContentSizeCategoryChange() {
        // 重新配置外观以适应新的字体大小
        configureAppearance()
    }
}

// MARK: - Accessibility Support

extension AppearanceManager {
    
    /// 配置无障碍功能支持
    func configureAccessibilitySupport() {
        // 监听对比度变化
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleAccessibilityChange()
            }
        }
        
        // 监听减少透明度变化
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleAccessibilityChange()
            }
        }
    }
    
    @MainActor
    private func handleAccessibilityChange() {
        // 重新配置外观以适应无障碍设置
        configureAppearance()
    }
}
