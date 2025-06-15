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
    var placeholderLabel: UILabel? {
        get {
            getIvar(forKey: "_placeholderLabel") as? UILabel
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
    
    /// 移除 placeholder
    func removePlaceholder() {
        placeholderLabel?.removeFromSuperview()
        placeholderLabel = nil
        
        // 移除通知监听
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
    // MARK: - Private Methods
    
    private func setupPlaceholderLabel() {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.encodifySecondaryText
        label.font = self.font ?? UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        
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
        
        // 计算正确的边距
        let topMargin = contentInset.top + textContainerInset.top
        let leadingMargin = contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding
        let trailingMargin = contentInset.right + textContainerInset.right + textContainer.lineFragmentPadding
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: topMargin),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingMargin),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -trailingMargin)
        ])
        
        // 设置宽度约束，防止超出边界
        updatePlaceholderWidth()
    }
    
    private func updatePlaceholderWidth() {
        guard let label = placeholderLabel else { return }
        
        let availableWidth = bounds.width 
            - contentInset.left - contentInset.right 
            - textContainerInset.left - textContainerInset.right 
            - (textContainer.lineFragmentPadding * 2)
        
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
        updatePlaceholderWidthIfNeeded()
    }
    
    /// 内部方法：更新 placeholder 宽度（如果存在）
    private func updatePlaceholderWidthIfNeeded() {
        guard let label = placeholderLabel else { return }
        
        let availableWidth = bounds.width 
            - contentInset.left - contentInset.right 
            - textContainerInset.left - textContainerInset.right 
            - (textContainer.lineFragmentPadding * 2)
        
        label.preferredMaxLayoutWidth = max(0, availableWidth)
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
}

// MARK: - Theme Support

extension UITextView {
    
    /// 更新 placeholder 的主题外观
    @objc func updatePlaceholderTheme() {
        guard placeholderLabel != nil else { return }
        applyThemeToPlaceholder()
    }
}
