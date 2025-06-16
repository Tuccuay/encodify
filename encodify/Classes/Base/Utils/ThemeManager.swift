//
//  ThemeManager.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 简化的主题管理器
/// 完全跟随系统设置，无需手动管理主题切换
@MainActor
final class ThemeManager {
    
    // MARK: - Singleton
    
    static let shared = ThemeManager()
    
    private init() {}
    
    // MARK: - System Integration
    
    /// 当前是否为深色模式（直接读取系统）
    var isDarkMode: Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    /// 当前动态字体类别（直接读取系统）
    var contentSizeCategory: UIContentSizeCategory {
        return UITraitCollection.current.preferredContentSizeCategory
    }
    
    /// 获取当前系统主题的颜色配置
    /// - Returns: 主题颜色配置
    func getCurrentThemeColors() -> ThemeColors {
        return ThemeColors(isDarkMode: isDarkMode)
    }
}

// MARK: - Theme Colors

/// 主题颜色配置
struct ThemeColors {
    let isDarkMode: Bool
    
    // MARK: - Primary Colors
    
    var primaryTint: UIColor {
        return UIColor.encodifyTintColor
    }
    
    var secondaryAccent: UIColor {
        return UIColor.encodifySecondaryColor
    }
    
    // MARK: - Background Colors
    
    var primaryBackground: UIColor {
        return UIColor.systemBackground
    }
    
    var secondaryBackground: UIColor {
        return UIColor.secondarySystemBackground
    }
    
    var tertiaryBackground: UIColor {
        return UIColor.tertiarySystemBackground
    }
    
    var cardBackground: UIColor {
        return UIColor.encodifyCardBackground
    }
    
    var groupedBackground: UIColor {
        return UIColor.systemGroupedBackground
    }
    
    // MARK: - Text Colors
    
    var primaryText: UIColor {
        return UIColor.encodifyPrimaryText
    }
    
    var secondaryText: UIColor {
        return UIColor.encodifySecondaryText
    }
    
    var tertiaryText: UIColor {
        return UIColor.tertiaryLabel
    }
    
    var placeholderText: UIColor {
        return UIColor.placeholderText
    }
    
    // MARK: - Semantic Colors
    
    var successColor: UIColor {
        return UIColor.encodifySuccessColor
    }
    
    var warningColor: UIColor {
        return UIColor.encodifyWarningColor
    }
    
    var errorColor: UIColor {
        return UIColor.encodifyErrorColor
    }
    
    var infoColor: UIColor {
        return UIColor.encodifyInfoColor
    }
    
    // MARK: - Border and Separator Colors
    
    var borderColor: UIColor {
        return UIColor.encodifyBorderColor
    }
    
    var separatorColor: UIColor {
        return UIColor.separator
    }
    
    // MARK: - Shadow Colors
    
    var shadowColor: UIColor {
        return isDarkMode ? UIColor.white.withAlphaComponent(0.1) : UIColor.black.withAlphaComponent(0.15)
    }
    
    var cardShadowColor: UIColor {
        return isDarkMode ? UIColor.clear : UIColor.black.withAlphaComponent(0.1)
    }
}

// MARK: - Theme-Aware UI Components (移除复杂的基类)

// iOS 系统会自动处理深色模式和动态字体变化
// 如果需要响应主题变化，在具体的 ViewController 中重写 traitCollectionDidChange 方法即可

// MARK: - Theme Utilities

extension ThemeManager {
    
    /// 获取适配当前系统主题的颜色
    /// - Parameters:
    ///   - lightColor: 浅色模式颜色
    ///   - darkColor: 深色模式颜色
    /// - Returns: 适配后的颜色
    func adaptiveColor(light lightColor: UIColor, dark darkColor: UIColor) -> UIColor {
        return isDarkMode ? darkColor : lightColor
    }
    
    /// 获取适配当前系统主题的图片
    /// - Parameters:
    ///   - lightImage: 浅色模式图片
    ///   - darkImage: 深色模式图片
    /// - Returns: 适配后的图片
    func adaptiveImage(light lightImage: UIImage?, dark darkImage: UIImage?) -> UIImage? {
        return isDarkMode ? darkImage : lightImage
    }
}

// MARK: - UIView Theme Extensions

extension UIView {
    
    /// 应用主题感知的阴影
    /// - Parameters:
    ///   - radius: 阴影半径
    ///   - opacity: 阴影不透明度
    ///   - offset: 阴影偏移
    func applyThemeAwareShadow(radius: CGFloat = 8, opacity: Float = 0.15, offset: CGSize = CGSize(width: 0, height: 4)) {
        let colors = ThemeManager.shared.getCurrentThemeColors()
        
        layer.shadowColor = colors.shadowColor.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.masksToBounds = false
        
        // 为性能优化设置阴影路径
        DispatchQueue.main.async {
            self.layer.shadowPath = UIBezierPath(
                roundedRect: self.bounds,
                cornerRadius: self.layer.cornerRadius
            ).cgPath
        }
    }
    
    /// 应用主题感知的边框
    /// - Parameters:
    ///   - width: 边框宽度
    ///   - cornerRadius: 圆角半径
    func applyThemeAwareBorder(width: CGFloat = 1, cornerRadius: CGFloat = 8) {
        let colors = ThemeManager.shared.getCurrentThemeColors()
        
        layer.borderColor = colors.borderColor.cgColor
        layer.borderWidth = width
        layer.cornerRadius = cornerRadius
    }
}
