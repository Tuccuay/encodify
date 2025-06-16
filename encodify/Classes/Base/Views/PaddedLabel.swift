//
//  PaddedLabel.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 支持内边距的 UILabel
///
/// `PaddedLabel` 提供了为 UILabel 添加内边距的功能，类似于 CSS 中的 padding。
/// 这在需要精确控制文本位置、与其他组件对齐时特别有用。
///
/// ## 使用场景
/// - UITextView placeholder 对齐
/// - 按钮内文本的精确定位
/// - 需要内边距但不想使用容器视图的场景
/// - 自定义控件中的文本布局
///
/// ## 使用示例
/// ```swift
/// let label = PaddedLabel()
/// label.text = "带内边距的标签"
/// label.textInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
/// ```
///
/// ## 特性
/// - 支持所有方向的内边距设置
/// - 自动计算正确的 intrinsicContentSize
/// - 兼容 Auto Layout
/// - 支持多行文本
/// - 性能优化，只在需要时重新绘制
open class PaddedLabel: UILabel {
    
    // MARK: - Properties
    
    /// 文本内边距
    ///
    /// 设置后会自动触发重新布局和绘制。
    /// 内边距会影响标签的 intrinsicContentSize 和文本绘制位置。
    @IBInspectable
    open var textInsets: UIEdgeInsets = .zero {
        didSet {
            guard textInsets != oldValue else { return }
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    // MARK: - Convenience Properties
    
    /// 顶部内边距（便捷属性）
    @IBInspectable
    open var paddingTop: CGFloat {
        get { textInsets.top }
        set { textInsets.top = newValue }
    }
    
    /// 左侧内边距（便捷属性）
    @IBInspectable
    open var paddingLeft: CGFloat {
        get { textInsets.left }
        set { textInsets.left = newValue }
    }
    
    /// 底部内边距（便捷属性）
    @IBInspectable
    open var paddingBottom: CGFloat {
        get { textInsets.bottom }
        set { textInsets.bottom = newValue }
    }
    
    /// 右侧内边距（便捷属性）
    @IBInspectable
    open var paddingRight: CGFloat {
        get { textInsets.right }
        set { textInsets.right = newValue }
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    /// 使用指定内边距初始化
    /// - Parameter textInsets: 文本内边距
    public convenience init(textInsets: UIEdgeInsets) {
        self.init(frame: .zero)
        self.textInsets = textInsets
    }
    
    private func commonInit() {
        // 设置默认配置
        if textInsets == .zero {
            // 提供合理的默认内边距
            textInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        }
    }
    
    // MARK: - Overrides
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        // 计算去除内边距后的可用区域
        let insetRect = bounds.inset(by: textInsets)
        
        // 获取在可用区域内的文本矩形
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        
        // 将文本矩形扩展回包含内边距的完整区域
        let invertedInsets = UIEdgeInsets(
            top: -textInsets.top,
            left: -textInsets.left,
            bottom: -textInsets.bottom,
            right: -textInsets.right
        )
        
        return textRect.inset(by: invertedInsets)
    }
    
    open override func drawText(in rect: CGRect) {
        // 在绘制时应用内边距，确保文本在正确位置绘制
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    open override var intrinsicContentSize: CGSize {
        guard text?.isEmpty == false else {
            // 没有文本时，返回只包含内边距的尺寸
            return CGSize(
                width: textInsets.left + textInsets.right,
                height: textInsets.top + textInsets.bottom
            )
        }
        
        // 获取原始内容尺寸并添加内边距
        var contentSize = super.intrinsicContentSize
        contentSize.width += textInsets.left + textInsets.right
        contentSize.height += textInsets.top + textInsets.bottom
        
        return contentSize
    }
    
    // MARK: - Public Methods
    
    /// 设置统一的内边距
    /// - Parameter padding: 四个方向统一的内边距值
    open func setPadding(_ padding: CGFloat) {
        textInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    /// 设置水平和垂直内边距
    /// - Parameters:
    ///   - horizontal: 左右内边距
    ///   - vertical: 上下内边距
    open func setPadding(horizontal: CGFloat, vertical: CGFloat) {
        textInsets = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
    /// 设置具体的内边距值
    /// - Parameters:
    ///   - top: 顶部内边距
    ///   - left: 左侧内边距
    ///   - bottom: 底部内边距
    ///   - right: 右侧内边距
    open func setPadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        textInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

// MARK: - Theme Support

extension PaddedLabel {
    
    /// 应用主题样式
    /// - Parameter style: 文本样式
    func applyStyle(_ style: TextStyler.Style) {
        textColor = style.color
        font = UIFont.preferredFont(forTextStyle: style.textStyle)
    }
}

// MARK: - Auto Layout Helpers

extension PaddedLabel {
    
    /// 创建一个带有指定样式和内边距的标签
    /// - Parameters:
    ///   - text: 显示文本
    ///   - style: 文本样式
    ///   - padding: 内边距
    /// - Returns: 配置好的 PaddedLabel 实例
    static func create(
        text: String,
        style: TextStyler.Style = .body,
        padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    ) -> PaddedLabel {
        let label = PaddedLabel(textInsets: padding)
        label.text = text
        label.applyStyle(style)
        label.adjustsFontForContentSizeCategory = true
        return label
    }
    
    /// 创建一个用于 placeholder 的标签
    /// - Parameters:
    ///   - text: placeholder 文本
    ///   - padding: 手动指定的内边距（可选）
    ///   - font: 字体（可选）
    /// - Returns: 配置好的 placeholder 标签
    static func createPlaceholder(
        text: String,
        padding: UIEdgeInsets = .zero,
        font: UIFont? = nil
    ) -> PaddedLabel {
        let label = PaddedLabel(textInsets: padding)
        label.text = text
        label.font = font ?? UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.encodifySecondaryText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        
        return label
    }
}
