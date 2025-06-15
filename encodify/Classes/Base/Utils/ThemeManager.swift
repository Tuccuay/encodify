//
//  ThemeManager.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 主题管理器
/// 负责跟随系统的主题设置和动态字体配置
@MainActor
final class ThemeManager {
    
    // MARK: - Singleton
    
    static let shared = ThemeManager()
    
    private init() {
        setupSystemObservers()
    }
    
    // MARK: - System Integration
    
    /// 系统主题变更通知
    static let systemThemeDidChangeNotification = Notification.Name("SystemThemeDidChange")
    
    /// 当前是否为深色模式（跟随系统）
    var isDarkMode: Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    /// 当前动态字体类别（跟随系统）
    var contentSizeCategory: UIContentSizeCategory {
        return UITraitCollection.current.preferredContentSizeCategory
    }
    
    // MARK: - Public Methods
    
    /// 获取当前系统主题的颜色配置
    /// - Returns: 主题颜色配置
    func getCurrentThemeColors() -> ThemeColors {
        return ThemeColors(isDarkMode: isDarkMode)
    }
    
    // MARK: - Private Methods
    
    private func setupSystemObservers() {
        // 监听系统主题变化
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.notifySystemThemeChange()
            }
        }
        
        // 监听动态字体变化
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
    private func notifySystemThemeChange() {
        NotificationCenter.default.post(name: Self.systemThemeDidChangeNotification, object: self)
    }
    
    @MainActor
    private func handleContentSizeCategoryChange() {
        // 字体大小变化时重新配置外观
        AppearanceManager.shared.configureAppearance()
        notifySystemThemeChange()
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

// MARK: - Theme-Aware UI Components

/// 主题感知的视图基类（跟随系统主题）
@MainActor
class ThemeAwareView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSystemObserver()
        applyTheme()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSystemObserver()
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupSystemObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemThemeDidChange),
            name: ThemeManager.systemThemeDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func systemThemeDidChange() {
        applyTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) ||
           traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            applyTheme()
        }
    }
    
    /// 子类重写此方法来应用主题
    func applyTheme() {
        let colors = ThemeManager.shared.getCurrentThemeColors()
        backgroundColor = colors.primaryBackground
    }
}

/// 主题感知的视图控制器基类（跟随系统主题）
@MainActor
class ThemeAwareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSystemObserver()
        applyTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupSystemObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemThemeDidChange),
            name: ThemeManager.systemThemeDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func systemThemeDidChange() {
        applyTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) ||
           traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            applyTheme()
        }
    }
    
    /// 子类重写此方法来应用主题
    func applyTheme() {
        let colors = ThemeManager.shared.getCurrentThemeColors()
        view.backgroundColor = colors.primaryBackground
        
        // 更新状态栏样式
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.isDarkMode ? .lightContent : .darkContent
    }
}

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
