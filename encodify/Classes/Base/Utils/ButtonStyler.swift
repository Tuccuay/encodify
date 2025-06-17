//
//  ButtonStyler.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 按钮样式配置器
/// 提供现代化的按钮样式配置，遵循 iOS 16.6+ 设计规范
@MainActor
struct ButtonStyler {
    
    // MARK: - Button Styles
    
    enum Style {
        case primary        // 主要按钮 - 填充样式
        case secondary      // 次要按钮 - 描边样式
        case tertiary       // 第三级按钮 - 文字样式
        case destructive    // 危险操作按钮
        case plain          // 纯文字按钮
    }
    
    enum Size {
        case large          // 大尺寸 - 高度 50pt
        case medium         // 中等尺寸 - 高度 44pt
        case small          // 小尺寸 - 高度 36pt
        case compact        // 紧凑尺寸 - 高度 28pt
        
        var height: CGFloat {
            switch self {
            case .large: return 50
            case .medium: return 44
            case .small: return 36
            case .compact: return 28
            }
        }
        
        var textStyle: UIFont.TextStyle {
            switch self {
            case .large: return .body
            case .medium: return .callout
            case .small: return .callout
            case .compact: return .caption1
            }
        }
        
        var cornerRadius: CGFloat {
            return height * 0.28 // 约为高度的 28%，符合现代设计
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .large: return 24
            case .medium: return 20
            case .small: return 16
            case .compact: return 12
            }
        }
    }
    
    // MARK: - Configuration Methods
    
    /// 配置按钮样式
    /// - Parameters:
    ///   - button: 要配置的按钮
    ///   - style: 按钮样式
    ///   - size: 按钮尺寸
    ///   - isEnabled: 是否启用
    static func configure(_ button: UIButton, style: Style, size: Size = .medium, isEnabled: Bool = true) {
        // 基础配置
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: size.textStyle)
        button.layer.cornerRadius = size.cornerRadius
        button.layer.masksToBounds = false
        button.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: size.horizontalPadding,
            bottom: 0,
            right: size.horizontalPadding
        )
        
        // 配置按钮约束（如果需要）
        button.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        // 样式特定配置
        configureStyle(button, style: style, isEnabled: isEnabled)
        
        // 交互动画配置
        configureInteractionAnimation(button)
        
        // 无障碍配置
        configureAccessibility(button, style: style)
    }
    
    // MARK: - Private Configuration Methods
    
    private static func configureStyle(_ button: UIButton, style: Style, isEnabled: Bool) {
        switch style {
        case .primary:
            configurePrimaryStyle(button, isEnabled: isEnabled)
        case .secondary:
            configureSecondaryStyle(button, isEnabled: isEnabled)
        case .tertiary:
            configureTertiaryStyle(button, isEnabled: isEnabled)
        case .destructive:
            configureDestructiveStyle(button, isEnabled: isEnabled)
        case .plain:
            configurePlainStyle(button, isEnabled: isEnabled)
        }
    }
    
    private static func configurePrimaryStyle(_ button: UIButton, isEnabled: Bool) {
        if isEnabled {
            button.backgroundColor = UIColor.encodifyTintColor
            button.setTitleColor(.white, for: .normal)
            
            // 阴影效果
            button.layer.shadowColor = UIColor.encodifyTintColor.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 8
            button.layer.shadowOpacity = 0.25
        } else {
            button.backgroundColor = UIColor.encodifyBorderColor
            button.setTitleColor(UIColor.encodifySecondaryText, for: .normal)
            button.layer.shadowOpacity = 0
        }
    }
    
    private static func configureSecondaryStyle(_ button: UIButton, isEnabled: Bool) {
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 1.5
        
        if isEnabled {
            button.layer.borderColor = UIColor.encodifyTintColor.cgColor
            button.setTitleColor(UIColor.encodifyTintColor, for: .normal)
        } else {
            button.layer.borderColor = UIColor.encodifyBorderColor.cgColor
            button.setTitleColor(UIColor.encodifySecondaryText, for: .normal)
        }
        
        button.layer.shadowOpacity = 0
    }
    
    private static func configureTertiaryStyle(_ button: UIButton, isEnabled: Bool) {
        button.backgroundColor = UIColor.encodifySecondaryBackground
        button.layer.borderWidth = 0
        
        if isEnabled {
            button.setTitleColor(UIColor.encodifyTintColor, for: .normal)
        } else {
            button.setTitleColor(UIColor.encodifySecondaryText, for: .normal)
        }
        
        button.layer.shadowOpacity = 0
    }
    
    private static func configureDestructiveStyle(_ button: UIButton, isEnabled: Bool) {
        if isEnabled {
            button.backgroundColor = UIColor.encodifyErrorColor
            button.setTitleColor(.white, for: .normal)
            
            // 阴影效果
            button.layer.shadowColor = UIColor.encodifyErrorColor.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
            button.layer.shadowRadius = 8
            button.layer.shadowOpacity = 0.25
        } else {
            button.backgroundColor = UIColor.encodifyBorderColor
            button.setTitleColor(UIColor.encodifySecondaryText, for: .normal)
            button.layer.shadowOpacity = 0
        }
    }
    
    private static func configurePlainStyle(_ button: UIButton, isEnabled: Bool) {
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 0
        button.layer.shadowOpacity = 0
        
        if isEnabled {
            button.setTitleColor(UIColor.encodifyTintColor, for: .normal)
        } else {
            button.setTitleColor(UIColor.encodifySecondaryText, for: .normal)
        }
    }
    
    private static func configureInteractionAnimation(_ button: UIButton) {
        // 添加触摸动画
        button.addTarget(button, action: #selector(UIButton.touchDownAnimation), for: .touchDown)
        button.addTarget(button, action: #selector(UIButton.touchUpAnimation), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private static func configureAccessibility(_ button: UIButton, style: Style) {
        // 配置无障碍特性
        button.accessibilityTraits = .button
        
        // 根据样式设置无障碍提示
        switch style {
        case .destructive:
            button.accessibilityHint = "危险操作"
        default:
            break
        }
    }
}

// MARK: - UIButton Animation Extensions

private extension UIButton {
    
    @objc func touchDownAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.alpha = 0.8
        }
    }
    
    @objc func touchUpAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: [.allowUserInteraction, .curveEaseOut]) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}

// MARK: - UIButton Convenience Methods

extension UIButton {
    
    /// 快速配置按钮样式
    /// - Parameters:
    ///   - style: 按钮样式
    ///   - size: 按钮尺寸
    ///   - title: 按钮标题
    ///   - isEnabled: 是否启用
    func applyStyle(_ style: ButtonStyler.Style, size: ButtonStyler.Size = .medium, title: String? = nil, isEnabled: Bool = true) {
        if let title = title {
            setTitle(title, for: .normal)
        }
        
        ButtonStyler.configure(self, style: style, size: size, isEnabled: isEnabled)
    }
}
