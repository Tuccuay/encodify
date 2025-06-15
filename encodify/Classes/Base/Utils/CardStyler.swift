//
//  CardStyler.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 卡片样式配置器
/// 提供现代化的卡片样式配置，遵循 iOS 16.6+ 设计规范
@MainActor
struct CardStyler {
    
    // MARK: - Card Styles
    
    enum Style {
        case elevated       // 悬浮卡片 - 带阴影
        case outlined       // 描边卡片 - 带边框
        case filled         // 填充卡片 - 背景色
        case plain          // 简单卡片 - 无装饰
    }
    
    enum Elevation {
        case none           // 无阴影
        case low            // 低阴影
        case medium         // 中等阴影
        case high           // 高阴影
        
        var shadowRadius: CGFloat {
            switch self {
            case .none: return 0
            case .low: return 4
            case .medium: return 8
            case .high: return 16
            }
        }
        
        var shadowOpacity: Float {
            switch self {
            case .none: return 0
            case .low: return 0.08
            case .medium: return 0.15
            case .high: return 0.25
            }
        }
        
        var shadowOffset: CGSize {
            switch self {
            case .none: return .zero
            case .low: return CGSize(width: 0, height: 2)
            case .medium: return CGSize(width: 0, height: 4)
            case .high: return CGSize(width: 0, height: 8)
            }
        }
    }
    
    enum CornerRadius {
        case none           // 无圆角
        case small          // 小圆角 - 8pt
        case medium         // 中等圆角 - 12pt
        case large          // 大圆角 - 16pt
        case extraLarge     // 超大圆角 - 24pt
        case custom(CGFloat) // 自定义圆角
        
        var value: CGFloat {
            switch self {
            case .none: return 0
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            case .extraLarge: return 24
            case .custom(let radius): return radius
            }
        }
    }
    
    // MARK: - Configuration Methods
    
    /// 配置卡片样式
    /// - Parameters:
    ///   - view: 要配置的视图
    ///   - style: 卡片样式
    ///   - cornerRadius: 圆角大小
    ///   - elevation: 阴影级别
    ///   - backgroundColor: 背景色（可选）
    static func configure(
        _ view: UIView,
        style: Style,
        cornerRadius: CornerRadius = .medium,
        elevation: Elevation = .medium,
        backgroundColor: UIColor? = nil
    ) {
        // 基础配置
        view.layer.cornerRadius = cornerRadius.value
        view.layer.masksToBounds = false
        
        // 样式特定配置
        configureStyle(view, style: style, backgroundColor: backgroundColor)
        
        // 阴影配置
        configureElevation(view, elevation: elevation)
        
        // 无障碍配置
        configureAccessibility(view)
    }
    
    /// 配置内容边距
    /// - Parameters:
    ///   - view: 要配置的视图
    ///   - padding: 内边距
    static func configureContentPadding(_ view: UIView, padding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)) {
        // 如果视图有子视图，调整它们的约束
        if let contentView = view.subviews.first {
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
                contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
                contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right),
                contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom)
            ])
        }
    }
    
    // MARK: - Private Configuration Methods
    
    private static func configureStyle(_ view: UIView, style: Style, backgroundColor: UIColor?) {
        switch style {
        case .elevated:
            view.backgroundColor = backgroundColor ?? UIColor.encodifyCardBackground
            view.layer.borderWidth = 0
            
        case .outlined:
            view.backgroundColor = backgroundColor ?? UIColor.clear
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.encodifyBorderColor.cgColor
            
        case .filled:
            view.backgroundColor = backgroundColor ?? UIColor.encodifySecondaryBackground
            view.layer.borderWidth = 0
            
        case .plain:
            view.backgroundColor = backgroundColor ?? UIColor.clear
            view.layer.borderWidth = 0
        }
    }
    
    private static func configureElevation(_ view: UIView, elevation: Elevation) {
        // 阴影配置 - 使用主题感知颜色
        let themeColors = ThemeManager.shared.getCurrentThemeColors()
        view.layer.shadowColor = themeColors.shadowColor.cgColor
        view.layer.shadowOffset = elevation.shadowOffset
        view.layer.shadowRadius = elevation.shadowRadius
        view.layer.shadowOpacity = elevation.shadowOpacity
        
        // 性能优化：设置阴影路径
        if elevation != .none {
            DispatchQueue.main.async {
                view.layer.shadowPath = UIBezierPath(
                    roundedRect: view.bounds,
                    cornerRadius: view.layer.cornerRadius
                ).cgPath
            }
        }
    }
    
    private static func configureAccessibility(_ view: UIView) {
        // 为卡片添加无障碍特性
        view.isAccessibilityElement = false // 让子元素处理无障碍
        view.accessibilityContainerType = .semanticGroup
    }
}

// MARK: - Preset Card Configurations

extension CardStyler {
    
    /// 内容卡片预设样式
    static func contentCard(_ view: UIView) {
        configure(view, style: .elevated, cornerRadius: .large, elevation: .low)
        configureContentPadding(view, padding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }
    
    /// 列表项卡片预设样式
    static func listItemCard(_ view: UIView) {
        configure(view, style: .filled, cornerRadius: .medium, elevation: .none)
        configureContentPadding(view, padding: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    }
    
    /// 输入框卡片预设样式
    static func inputCard(_ view: UIView) {
        configure(view, style: .outlined, cornerRadius: .medium, elevation: .none)
        configureContentPadding(view, padding: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    }
    
    /// 结果显示卡片预设样式
    static func resultCard(_ view: UIView) {
        configure(view, style: .elevated, cornerRadius: .large, elevation: .medium)
        configureContentPadding(view, padding: UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20))
    }
    
    /// 工具栏卡片预设样式
    static func toolbarCard(_ view: UIView) {
        configure(view, style: .filled, cornerRadius: .small, elevation: .none)
        configureContentPadding(view, padding: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
    }
}

// MARK: - UIView Convenience Methods

extension UIView {
    
    /// 快速应用卡片样式
    /// - Parameters:
    ///   - style: 卡片样式
    ///   - cornerRadius: 圆角大小
    ///   - elevation: 阴影级别
    ///   - backgroundColor: 背景色
    func applyCardStyle(
        _ style: CardStyler.Style,
        cornerRadius: CardStyler.CornerRadius = .medium,
        elevation: CardStyler.Elevation = .medium,
        backgroundColor: UIColor? = nil
    ) {
        CardStyler.configure(self, style: style, cornerRadius: cornerRadius, elevation: elevation, backgroundColor: backgroundColor)
    }
    
    /// 应用内容卡片样式
    func applyContentCardStyle() {
        CardStyler.contentCard(self)
    }
    
    /// 应用列表项卡片样式
    func applyListItemCardStyle() {
        CardStyler.listItemCard(self)
    }
    
    /// 应用输入框卡片样式
    func applyInputCardStyle() {
        CardStyler.inputCard(self)
    }
    
    /// 应用结果显示卡片样式
    func applyResultCardStyle() {
        CardStyler.resultCard(self)
    }
    
    /// 应用工具栏卡片样式
    func applyToolbarCardStyle() {
        CardStyler.toolbarCard(self)
    }
}

// MARK: - Shadow Path Update Helper

extension UIView {
    
    /// 更新阴影路径（在视图布局变化后调用）
    func updateShadowPath() {
        if layer.shadowOpacity > 0 {
            layer.shadowPath = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: layer.cornerRadius
            ).cgPath
        }
    }
}
