//
//  UITextView+Placeholder.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

// MARK: - UITextView Placeholder Extension

public extension UITextView {
    
    // MARK: - Properties
    
    /// Placeholder label
    var placeholderLabel: PaddedLabel? {
        get {
            getIvar(forKey: "_placeholderLabel") as? PaddedLabel
        }
        set {
            setIvar(newValue, forKey: "_placeholderLabel")
        }
    }
    
    /// Placeholder 颜色
    var placeholderColor: UIColor? {
        get {
            placeholderLabel?.textColor
        }
        set {
            placeholderLabel?.textColor = newValue
        }
    }
    
    /// Placeholder 文本
    @IBInspectable
    var placeholder: String? {
        get {
            placeholderLabel?.text
        }
        set {
            if let text = newValue, !text.isEmpty {
                if placeholderLabel == nil {
                    setupPlaceholderLabel()
                    setupNotifications()
                }
                placeholderLabel?.text = text
                updatePlaceholderVisibility()
            } else {
                removePlaceholder()
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 设置 placeholder（完整配置方法）
    /// - Parameters:
    ///   - text: placeholder 文本
    ///   - color: placeholder 颜色（可选，默认使用主题颜色）
    ///   - font: placeholder 字体（可选，默认使用 textView 的字体）
    func setPlaceholder(
        _ text: String,
        color: UIColor? = nil,
        font: UIFont? = nil
    ) {
        self.placeholder = text
        self.placeholderColor = color ?? UIColor.encodifySecondaryText
        if let placeholderLabel = self.placeholderLabel {
            placeholderLabel.font = font ?? self.font ?? UIFont.preferredFont(forTextStyle: .body)
        }
    }
    
    /// 设置 placeholder 的内边距
    /// - Parameter padding: 内边距
    func setPlaceholderPadding(_ padding: UIEdgeInsets) {
        placeholderLabel?.textInsets = padding
    }
    
    /// 设置统一的 placeholder 内边距
    /// - Parameter padding: 四个方向统一的内边距值
    func setPlaceholderPadding(_ padding: CGFloat) {
        let insets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        placeholderLabel?.textInsets = insets
    }
    
    /// 移除 placeholder
    func removePlaceholder() {
        placeholderLabel?.removeFromSuperview()
        placeholderLabel = nil
        
        // 移除通知监听
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
    // MARK: - Private Methods
    
    private func setupPlaceholderLabel() {
        // 使用简单的创建方法，不自动计算对齐
        let label = PaddedLabel.createPlaceholder(text: "", padding: .zero)
        
        // 设置优先级，防止水平扩展
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        addSubview(label)
        placeholderLabel = label
        
        // 设置约束
        setupPlaceholderConstraints()
    }
    
    private func setupPlaceholderConstraints() {
        guard let label = placeholderLabel else { return }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 简单约束，边距通过 PaddedLabel 的 textInsets 处理
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
        
        // 设置宽度约束，防止超出边界
        updatePlaceholderWidth()
    }
    
    private func updatePlaceholderWidth() {
        guard let label = placeholderLabel else { return }
        
        // 简化宽度计算
        let availableWidth = bounds.width
        label.preferredMaxLayoutWidth = max(0, availableWidth)
    }
    
    private func setupNotifications() {
        // 监听文本变化
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }
    
    @objc private func textDidChange() {
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel?.isHidden = !text.isEmpty
    }
}

// MARK: - Layout Support

extension UITextView {
    
    /// 重写 layoutSubviews 以支持 placeholder 布局更新
    open override func layoutSubviews() {
        super.layoutSubviews()
        updatePlaceholderLayoutIfNeeded()
    }
    
    /// 内部方法：更新 placeholder 布局（如果存在）
    private func updatePlaceholderLayoutIfNeeded() {
        guard let label = placeholderLabel else { return }
        
        // 简化：只更新宽度，padding 由外部手动设置
        updatePlaceholderWidth()
    }
    
    /// 重新设置 placeholder 约束（当布局参数发生变化时）
    private func updatePlaceholderConstraintsIfNeeded() {
        // 现在使用 PaddedLabel，约束相对简单且稳定，通常不需要重新设置
        // 只需要更新宽度即可
        updatePlaceholderWidth()
    }
}

// MARK: - Convenience Methods

extension UITextView {
    
    /// 快速设置带样式的 placeholder
    /// - Parameters:
    ///   - text: placeholder 文本
    ///   - style: 文本样式（使用 TextStyler.Style）
    func setPlaceholder(_ text: String, style: TextStyler.Style = .inputPlaceholder) {
        setPlaceholder(
            text,
            color: style.color,
            font: UIFont.preferredFont(forTextStyle: style.textStyle)
        )
    }
    
    /// 应用主题样式到 placeholder
    func applyThemeToPlaceholder() {
        placeholderColor = UIColor.encodifySecondaryText
    }
    
    /// 调试方法：打印 placeholder 对齐信息
    func debugPlaceholderAlignment() {
        guard let label = placeholderLabel else {
            print("❌ Placeholder 未设置")
            return
        }
        
        print("🔍 UITextView Placeholder 对齐调试:")
        print("   • contentInset: \(contentInset)")
        print("   • textContainerInset: \(textContainerInset)")
        print("   • lineFragmentPadding: \(textContainer.lineFragmentPadding)")
        print("   • placeholderLabel.textInsets: \(label.textInsets)")
        print("")
        
        let textViewTextTop = contentInset.top + textContainerInset.top
        let textViewTextLeft = contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding
        
        let placeholderConstraintTop = contentInset.top
        let placeholderConstraintLeft = contentInset.left
        let placeholderTextTop = placeholderConstraintTop + label.textInsets.top
        let placeholderTextLeft = placeholderConstraintLeft + label.textInsets.left
        
        print("   • UITextView 文本位置: top=\(textViewTextTop), left=\(textViewTextLeft)")
        print("   • Placeholder 约束位置: top=\(placeholderConstraintTop), left=\(placeholderConstraintLeft)")
        print("   • Placeholder 文本位置: top=\(placeholderTextTop), left=\(placeholderTextLeft)")
        print("")
        
        let isAligned = (textViewTextTop == placeholderTextTop) && (textViewTextLeft == placeholderTextLeft)
        print("   • 对齐状态: \(isAligned ? "✅ 对齐" : "❌ 不对齐")")
    }
    
    /// 视觉调试方法：给 placeholder 添加背景色以便观察位置
    func enableVisualPlaceholderDebugging() {
        guard let label = placeholderLabel else { return }
        
        // 给 placeholder 添加半透明背景，便于观察位置
        label.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
        
        // 给 UITextView 添加半透明背景，便于观察文本区域
        self.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        
        print("🎨 已启用视觉调试：placeholder 为红色背景，UITextView 为蓝色背景")
    }
    
    /// 禁用视觉调试
    func disableVisualPlaceholderDebugging() {
        guard let label = placeholderLabel else { return }
        label.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.encodifyCardBackground
    }
}

// MARK: - Theme Support

extension UITextView {
    
    /// 更新 placeholder 的主题外观
    @objc func updatePlaceholderTheme() {
        guard placeholderLabel != nil else { return }
        applyThemeToPlaceholder()
    }
}
