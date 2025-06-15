//
//  ResponsiveDesignHelper.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 响应式设计辅助工具
/// 提供跨设备尺寸适配的工具方法，支持现代化的响应式布局
@MainActor
struct ResponsiveDesignHelper {
    
    // MARK: - Device Categories
    
    /// 设备类型分类
    enum DeviceCategory {
        case compactPhone      // 小屏手机 (iPhone SE, Mini)
        case regularPhone      // 常规手机 (iPhone 15)
        case largPhone         // 大屏手机 (iPhone 15 Plus, Pro Max)
        case compactPad        // 小型平板 (iPad Mini)
        case regularPad        // 常规平板 (iPad, iPad Air)
        case largePad          // 大型平板 (iPad Pro)
        
        /// 当前设备类型
        @MainActor
        static var current: DeviceCategory {
            let screenSize = UIScreen.main.bounds.size
            let maxDimension = max(screenSize.width, screenSize.height)
            let minDimension = min(screenSize.width, screenSize.height)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                if maxDimension <= 1080 { // iPad Mini
                    return .compactPad
                } else if maxDimension <= 1194 { // iPad, iPad Air
                    return .regularPad
                } else { // iPad Pro
                    return .largePad
                }
            } else {
                if maxDimension <= 667 { // iPhone SE, iPhone 8
                    return .compactPhone
                } else if maxDimension <= 844 { // iPhone 12, 13, 14, 15
                    return .regularPhone
                } else { // iPhone Plus, Pro Max
                    return .largPhone
                }
            }
        }
        
        var isPhone: Bool {
            switch self {
            case .compactPhone, .regularPhone, .largPhone:
                return true
            case .compactPad, .regularPad, .largePad:
                return false
            }
        }
        
        var isPad: Bool {
            return !isPhone
        }
    }
    
    // MARK: - Breakpoints
    
    /// 响应式断点
    enum Breakpoint {
        case xs     // 超小屏
        case sm     // 小屏
        case md     // 中等屏幕
        case lg     // 大屏
        case xl     // 超大屏
        
        /// 当前断点
        @MainActor
        static var current: Breakpoint {
            let width = UIScreen.main.bounds.width
            
            if width < 375 {
                return .xs
            } else if width < 414 {
                return .sm
            } else if width < 768 {
                return .md
            } else if width < 1024 {
                return .lg
            } else {
                return .xl
            }
        }
        
        /// 断点对应的基础字体缩放比例
        var fontScale: CGFloat {
            switch self {
            case .xs: return 0.9
            case .sm: return 1.0
            case .md: return 1.0
            case .lg: return 1.1
            case .xl: return 1.2
            }
        }
        
        /// 断点对应的间距缩放比例
        var spacingScale: CGFloat {
            switch self {
            case .xs: return 0.875
            case .sm: return 1.0
            case .md: return 1.0
            case .lg: return 1.125
            case .xl: return 1.25
            }
        }
    }
    
    // MARK: - Adaptive Values
    
    /// 响应式字体大小
    /// - Parameters:
    ///   - base: 基础字体大小
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 适配后的字体大小
    static func fontSize(
        base: CGFloat,
        phoneScale: CGFloat = 1.0,
        padScale: CGFloat = 1.15
    ) -> CGFloat {
        let deviceScale = DeviceCategory.current.isPad ? padScale : phoneScale
        let breakpointScale = Breakpoint.current.fontScale
        return base * deviceScale * breakpointScale
    }
    
    /// 响应式间距
    /// - Parameters:
    ///   - base: 基础间距
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 适配后的间距
    static func spacing(
        base: CGFloat,
        phoneScale: CGFloat = 1.0,
        padScale: CGFloat = 1.25
    ) -> CGFloat {
        let deviceScale = DeviceCategory.current.isPad ? padScale : phoneScale
        let breakpointScale = Breakpoint.current.spacingScale
        return base * deviceScale * breakpointScale
    }
    
    /// 响应式圆角大小
    /// - Parameters:
    ///   - base: 基础圆角大小
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 适配后的圆角大小
    static func cornerRadius(
        base: CGFloat,
        phoneScale: CGFloat = 1.0,
        padScale: CGFloat = 1.2
    ) -> CGFloat {
        let deviceScale = DeviceCategory.current.isPad ? padScale : phoneScale
        return base * deviceScale
    }
    
    /// 响应式阴影模糊半径
    /// - Parameters:
    ///   - base: 基础模糊半径
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 适配后的模糊半径
    static func shadowRadius(
        base: CGFloat,
        phoneScale: CGFloat = 1.0,
        padScale: CGFloat = 1.3
    ) -> CGFloat {
        let deviceScale = DeviceCategory.current.isPad ? padScale : phoneScale
        return base * deviceScale
    }
    
    // MARK: - Layout Adaptations
    
    /// 获取内容区域的推荐列数
    /// - Parameters:
    ///   - minItemWidth: 最小项目宽度
    ///   - spacing: 项目间距
    ///   - margins: 左右边距
    /// - Returns: 推荐列数
    static func recommendedColumns(
        minItemWidth: CGFloat,
        spacing: CGFloat = 16,
        margins: CGFloat = 32
    ) -> Int {
        let availableWidth = UIScreen.main.bounds.width - margins
        let itemWidthWithSpacing = minItemWidth + spacing
        let maxColumns = Int(availableWidth / itemWidthWithSpacing)
        
        // 根据设备类型调整列数
        switch DeviceCategory.current {
        case .compactPhone:
            return min(maxColumns, 1)
        case .regularPhone:
            return min(maxColumns, 2)
        case .largPhone:
            return min(maxColumns, 2)
        case .compactPad:
            return min(maxColumns, 3)
        case .regularPad:
            return min(maxColumns, 4)
        case .largePad:
            return min(maxColumns, 5)
        }
    }
    
    /// 获取推荐的内容最大宽度
    /// - Returns: 推荐的最大宽度
    static func recommendedMaxContentWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        
        switch DeviceCategory.current {
        case .compactPhone, .regularPhone, .largPhone:
            return screenWidth - 32 // 手机：左右各16pt边距
        case .compactPad:
            return min(screenWidth - 64, 600) // 小平板：最大600pt，左右各32pt边距
        case .regularPad:
            return min(screenWidth - 80, 700) // 常规平板：最大700pt，左右各40pt边距
        case .largePad:
            return min(screenWidth - 100, 800) // 大平板：最大800pt，左右各50pt边距
        }
    }
    
    /// 获取推荐的导航栏高度
    /// - Returns: 推荐的导航栏高度
    static func recommendedNavigationBarHeight() -> CGFloat {
        switch DeviceCategory.current {
        case .compactPhone:
            return 44
        case .regularPhone, .largPhone:
            return 44
        case .compactPad, .regularPad, .largePad:
            return 50
        }
    }
    
    /// 获取推荐的标签栏高度
    /// - Returns: 推荐的标签栏高度
    static func recommendedTabBarHeight() -> CGFloat {
        let baseHeight: CGFloat = 49
        let safeAreaBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        return baseHeight + safeAreaBottom
    }
    
    // MARK: - Typography Adaptations
    
    /// 响应式标题字体
    /// - Parameter level: 标题级别 (1-3)
    /// - Returns: 适配后的字体
    static func titleFont(level: Int) -> UIFont {
        let baseSizes: [CGFloat] = [34, 28, 22] // largeTitle, title1, title2
        let baseSize = baseSizes[min(max(level - 1, 0), 2)]
        let adaptiveSize = fontSize(base: baseSize)
        
        let weight: UIFont.Weight = level == 1 ? .bold : .semibold
        return UIFont.systemFont(ofSize: adaptiveSize, weight: weight)
    }
    
    /// 响应式正文字体
    /// - Parameter emphasis: 强调级别
    /// - Returns: 适配后的字体
    static func bodyFont(emphasis: TextEmphasis = .regular) -> UIFont {
        let baseSize: CGFloat = 17
        let adaptiveSize = fontSize(base: baseSize)
        return UIFont.systemFont(ofSize: adaptiveSize, weight: emphasis.weight)
    }
    
    /// 响应式说明文字字体
    /// - Returns: 适配后的字体
    static func captionFont() -> UIFont {
        let baseSize: CGFloat = 12
        let adaptiveSize = fontSize(base: baseSize)
        return UIFont.systemFont(ofSize: adaptiveSize, weight: .regular)
    }
    
    // MARK: - Supporting Types
    
    enum TextEmphasis {
        case light
        case regular
        case medium
        case semibold
        case bold
        
        var weight: UIFont.Weight {
            switch self {
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }
}

// MARK: - Device Information Extensions

extension ResponsiveDesignHelper {
    
    /// 设备信息
    struct DeviceInfo {
        let category: DeviceCategory
        let breakpoint: Breakpoint
        let screenSize: CGSize
        let safeAreaInsets: UIEdgeInsets
        let hasNotch: Bool
        let isLandscape: Bool
        
        /// 获取当前设备信息
        @MainActor
        static var current: DeviceInfo {
            let window = UIApplication.shared.windows.first
            let safeAreaInsets = window?.safeAreaInsets ?? .zero
            let screenSize = UIScreen.main.bounds.size
            let isLandscape = screenSize.width > screenSize.height
            let hasNotch = safeAreaInsets.top > 20 || safeAreaInsets.bottom > 0
            
            return DeviceInfo(
                category: DeviceCategory.current,
                breakpoint: Breakpoint.current,
                screenSize: screenSize,
                safeAreaInsets: safeAreaInsets,
                hasNotch: hasNotch,
                isLandscape: isLandscape
            )
        }
    }
    
    /// 获取设备信息
    /// - Returns: 当前设备信息
    static var deviceInfo: DeviceInfo {
        return DeviceInfo.current
    }
}

// MARK: - UIView Responsive Extensions

extension UIView {
    
    /// 应用响应式边距
    /// - Parameter base: 基础边距
    @MainActor
    func applyResponsiveMargins(base: CGFloat) {
        let adaptiveMargin = ResponsiveDesignHelper.spacing(base: base)
        layoutMargins = UIEdgeInsets.all(LayoutHelper.Spacing(rawValue: adaptiveMargin) ?? .medium)
    }
    
    /// 应用响应式圆角
    /// - Parameter base: 基础圆角大小
    @MainActor
    func applyResponsiveCornerRadius(base: CGFloat) {
        layer.cornerRadius = ResponsiveDesignHelper.cornerRadius(base: base)
    }
}

// MARK: - UIFont Responsive Extensions

extension UIFont {
    
    /// 创建响应式字体
    /// - Parameters:
    ///   - baseSize: 基础字体大小
    ///   - weight: 字体粗细
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 响应式字体
    @MainActor
    static func responsive(
        baseSize: CGFloat,
        weight: UIFont.Weight = .regular,
        phoneScale: CGFloat = 1.0,
        padScale: CGFloat = 1.15
    ) -> UIFont {
        let adaptiveSize = ResponsiveDesignHelper.fontSize(
            base: baseSize,
            phoneScale: phoneScale,
            padScale: padScale
        )
        return UIFont.systemFont(ofSize: adaptiveSize, weight: weight)
    }
}

// MARK: - CGFloat Responsive Extensions

extension CGFloat {
    
    /// 响应式间距
    /// - Parameters:
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 适配后的值
    @MainActor
    func responsive(phoneScale: CGFloat = 1.0, padScale: CGFloat = 1.25) -> CGFloat {
        return ResponsiveDesignHelper.spacing(base: self, phoneScale: phoneScale, padScale: padScale)
    }
    
    /// 响应式圆角
    /// - Parameters:
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 适配后的圆角大小
    @MainActor
    func responsiveCornerRadius(phoneScale: CGFloat = 1.0, padScale: CGFloat = 1.2) -> CGFloat {
        return ResponsiveDesignHelper.cornerRadius(base: self, phoneScale: phoneScale, padScale: padScale)
    }
}

// MARK: - UIEdgeInsets Responsive Extensions

extension UIEdgeInsets {
    
    /// 响应式边距
    /// - Parameters:
    ///   - base: 基础边距值
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 适配后的边距
    @MainActor
    static func responsive(
        base: CGFloat,
        phoneScale: CGFloat = 1.0,
        padScale: CGFloat = 1.25
    ) -> UIEdgeInsets {
        let adaptiveValue = ResponsiveDesignHelper.spacing(
            base: base,
            phoneScale: phoneScale,
            padScale: padScale
        )
        return UIEdgeInsets.all(LayoutHelper.Spacing(rawValue: adaptiveValue) ?? .medium)
    }
    
    /// 响应式对称边距
    /// - Parameters:
    ///   - horizontal: 水平边距基础值
    ///   - vertical: 垂直边距基础值
    ///   - phoneScale: 手机端缩放比例
    ///   - padScale: 平板端缩放比例
    /// - Returns: 适配后的边距
    @MainActor
    static func responsiveSymmetric(
        horizontal: CGFloat,
        vertical: CGFloat,
        phoneScale: CGFloat = 1.0,
        padScale: CGFloat = 1.25
    ) -> UIEdgeInsets {
        let adaptiveHorizontal = ResponsiveDesignHelper.spacing(
            base: horizontal,
            phoneScale: phoneScale,
            padScale: padScale
        )
        let adaptiveVertical = ResponsiveDesignHelper.spacing(
            base: vertical,
            phoneScale: phoneScale,
            padScale: padScale
        )
        return UIEdgeInsets.symmetric(
            horizontal: LayoutHelper.Spacing(rawValue: adaptiveHorizontal) ?? .medium,
            vertical: LayoutHelper.Spacing(rawValue: adaptiveVertical) ?? .medium
        )
    }
}
