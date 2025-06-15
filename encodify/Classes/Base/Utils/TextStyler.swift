//
//  TextStyler.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 文本样式配置器
/// 提供现代化的文本样式配置，支持动态字体和无障碍功能
@MainActor
struct TextStyler {
    
    // MARK: - Text Styles
    
    enum Style {
        // 标题样式
        case largeTitle     // 大标题
        case title1         // 标题1
        case title2         // 标题2
        case title3         // 标题3
        
        // 正文样式
        case headline       // 标题正文
        case body           // 正文
        case callout        // 重点正文
        case subheadline    // 副标题
        case footnote       // 脚注
        case caption1       // 说明文字1
        case caption2       // 说明文字2
        
        // 应用特定样式（映射到系统样式）
        case cardTitle      // 卡片标题 -> headline
        case cardSubtitle   // 卡片副标题 -> subheadline
        case buttonText     // 按钮文字 -> body
        case inputText      // 输入框文字 -> body
        case inputPlaceholder // 输入框占位符 -> footnote
        case resultText     // 结果文字 -> body
        case errorText      // 错误文字 -> caption1
        case successText    // 成功文字 -> caption1
        case warningText    // 警告文字 -> caption1
        
        var textStyle: UIFont.TextStyle {
            switch self {
            case .largeTitle: return .largeTitle
            case .title1: return .title1
            case .title2: return .title2
            case .title3: return .title3
            case .headline, .cardTitle: return .headline
            case .body, .inputText, .resultText, .buttonText: return .body
            case .callout: return .callout
            case .subheadline, .cardSubtitle: return .subheadline
            case .footnote, .inputPlaceholder: return .footnote
            case .caption1, .errorText, .successText, .warningText: return .caption1
            case .caption2: return .caption2
            }
        }
        
        var color: UIColor {
            switch self {
            case .largeTitle, .title1, .title2, .title3, .headline, .body, .callout,
                 .cardTitle, .inputText, .resultText: 
                return UIColor.encodifyPrimaryText
            case .subheadline, .footnote, .caption1, .caption2, .cardSubtitle:
                return UIColor.encodifySecondaryText
            case .buttonText:
                return UIColor.encodifyTintColor
            case .inputPlaceholder:
                return UIColor.placeholderText
            case .errorText:
                return UIColor.encodifyErrorColor
            case .successText:
                return UIColor.encodifySuccessColor
            case .warningText:
                return UIColor.encodifyWarningColor
            }
        }
    }
    
    // MARK: - Configuration Methods
    
    /// 配置标签文本样式
    /// - Parameters:
    ///   - label: 要配置的标签
    ///   - style: 文本样式
    ///   - numberOfLines: 行数限制
    ///   - textAlignment: 文本对齐方式
    static func configure(
        _ label: UILabel,
        style: Style,
        numberOfLines: Int = 0,
        textAlignment: NSTextAlignment = .natural
    ) {
        // 使用系统动态字体
        let font = UIFont.preferredFont(forTextStyle: style.textStyle)
        
        // 配置标签
        label.font = font
        label.textColor = style.color
        label.numberOfLines = numberOfLines
        label.textAlignment = textAlignment
        label.adjustsFontForContentSizeCategory = true
        
        // 配置行间距和段落样式
        configureLineSpacing(label, style: style)
        
        // 无障碍配置
        configureAccessibility(label, style: style)
    }
    
    /// 配置文本框样式
    /// - Parameters:
    ///   - textField: 要配置的文本框
    ///   - style: 文本样式
    ///   - placeholderStyle: 占位符样式
    static func configure(
        _ textField: UITextField,
        style: Style = .inputText,
        placeholderStyle: Style = .inputPlaceholder
    ) {
        // 配置主要文本
        textField.font = UIFont.preferredFont(forTextStyle: style.textStyle)
        textField.textColor = style.color
        textField.adjustsFontForContentSizeCategory = true
        
        // 配置占位符（如果有）
        if let placeholder = textField.placeholder {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: placeholderStyle.textStyle),
                .foregroundColor: placeholderStyle.color
            ]
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
        
        // 无障碍配置
        textField.accessibilityTraits = .none
    }
    
    /// 配置文本视图样式
    /// - Parameters:
    ///   - textView: 要配置的文本视图
    ///   - style: 文本样式
    static func configure(_ textView: UITextView, style: Style = .body) {
        textView.font = UIFont.preferredFont(forTextStyle: style.textStyle)
        textView.textColor = style.color
        textView.adjustsFontForContentSizeCategory = true
        
        // 配置行间距
        configureLineSpacing(textView, style: style)
    }
    
    /// 配置按钮文本样式
    /// - Parameters:
    ///   - button: 要配置的按钮
    ///   - style: 文本样式
    ///   - state: 按钮状态
    static func configure(_ button: UIButton, style: Style = .buttonText, for state: UIControl.State = .normal) {
        let font = UIFont.preferredFont(forTextStyle: style.textStyle)
        button.titleLabel?.font = font
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitleColor(style.color, for: state)
    }
    
    // MARK: - Line Spacing Configuration
    
    private static func configureLineSpacing(_ label: UILabel, style: Style) {
        guard let text = label.text, !text.isEmpty else { return }
        
        let lineSpacing = calculateLineSpacing(for: style)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = label.textAlignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: label.font ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: label.textColor ?? UIColor.label,
            .paragraphStyle: paragraphStyle
        ]
        
        label.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
    
    private static func configureLineSpacing(_ textView: UITextView, style: Style) {
        let lineSpacing = calculateLineSpacing(for: style)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        
        textView.typingAttributes = [
            .font: textView.font ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: textView.textColor ?? UIColor.label,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    private static func calculateLineSpacing(for style: Style) -> CGFloat {
        switch style {
        case .largeTitle, .title1, .title2, .title3:
            return 2.0
        case .headline, .body, .callout:
            return 1.5
        case .subheadline, .footnote, .caption1, .caption2:
            return 1.0
        case .cardTitle, .cardSubtitle, .buttonText, .inputText, .inputPlaceholder,
             .resultText, .errorText, .successText, .warningText:
            return 1.0
        }
    }
    
    // MARK: - Accessibility Configuration
    
    private static func configureAccessibility(_ label: UILabel, style: Style) {
        // 根据样式设置无障碍特性
        switch style {
        case .largeTitle, .title1, .title2, .title3, .headline, .cardTitle:
            label.accessibilityTraits = .header
        case .errorText:
            label.accessibilityTraits = .staticText
            label.accessibilityHint = "错误信息"
        case .successText:
            label.accessibilityTraits = .staticText
            label.accessibilityHint = "成功信息"
        case .warningText:
            label.accessibilityTraits = .staticText
            label.accessibilityHint = "警告信息"
        default:
            label.accessibilityTraits = .staticText
        }
    }
}

// MARK: - Attributed String Helpers

extension TextStyler {
    
    /// 创建带样式的属性字符串
    /// - Parameters:
    ///   - text: 文本内容
    ///   - style: 文本样式
    ///   - alignment: 对齐方式
    /// - Returns: 属性字符串
    static func createAttributedString(
        _ text: String,
        style: Style,
        alignment: NSTextAlignment = .natural
    ) -> NSAttributedString {
        let font = UIFont.preferredFont(forTextStyle: style.textStyle)
        let lineSpacing = calculateLineSpacing(for: style)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: style.color,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    /// 创建多样式属性字符串
    /// - Parameter components: 文本组件数组
    /// - Returns: 属性字符串
    static func createMultiStyleAttributedString(_ components: [(text: String, style: Style)]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for component in components {
            let attributedString = createAttributedString(component.text, style: component.style)
            result.append(attributedString)
        }
        
        return result
    }
}

// MARK: - UILabel Convenience Methods

extension UILabel {
    
    /// 快速设置文本样式
    /// - Parameters:
    ///   - text: 文本内容
    ///   - style: 文本样式
    ///   - numberOfLines: 行数限制
    ///   - textAlignment: 对齐方式
    func setText(
        _ text: String,
        style: TextStyler.Style,
        numberOfLines: Int = 0,
        textAlignment: NSTextAlignment = .natural
    ) {
        self.text = text
        TextStyler.configure(self, style: style, numberOfLines: numberOfLines, textAlignment: textAlignment)
    }
    
    /// 设置属性文本样式
    /// - Parameters:
    ///   - text: 文本内容
    ///   - style: 文本样式
    ///   - alignment: 对齐方式
    func setAttributedText(_ text: String, style: TextStyler.Style, alignment: NSTextAlignment = .natural) {
        attributedText = TextStyler.createAttributedString(text, style: style, alignment: alignment)
    }
}

// MARK: - UITextField Convenience Methods

extension UITextField {
    
    /// 快速设置文本框样式
    /// - Parameters:
    ///   - placeholder: 占位符文本
    ///   - style: 文本样式
    ///   - placeholderStyle: 占位符样式
    func configurePlaceholder(
        _ placeholder: String,
        style: TextStyler.Style = .inputText,
        placeholderStyle: TextStyler.Style = .inputPlaceholder
    ) {
        self.placeholder = placeholder
        TextStyler.configure(self, style: style, placeholderStyle: placeholderStyle)
    }
}

// MARK: - UITextView Convenience Methods

extension UITextView {
    
    /// 快速设置文本视图样式
    /// - Parameters:
    ///   - text: 文本内容
    ///   - style: 文本样式
    func setText(_ text: String, style: TextStyler.Style) {
        self.text = text
        TextStyler.configure(self, style: style)
    }
}

// MARK: - UIButton Convenience Methods

extension UIButton {
    
    /// 快速设置按钮文本样式
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - style: 文本样式
    ///   - state: 按钮状态
    func setTitle(_ title: String, style: TextStyler.Style, for state: UIControl.State = .normal) {
        setTitle(title, for: state)
        TextStyler.configure(self, style: style, for: state)
    }
}
