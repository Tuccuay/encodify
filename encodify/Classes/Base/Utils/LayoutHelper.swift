//
//  LayoutHelper.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 布局辅助工具
/// 提供现代化的约束布局方法，简化AutoLayout使用
@MainActor
struct LayoutHelper {
    
    // MARK: - Standard Spacing
    
    /// 标准间距值
    enum Spacing: CGFloat, CaseIterable {
        case none = 0           // 无间距
        case tiny = 4           // 微小间距
        case small = 8          // 小间距
        case medium = 16        // 中等间距
        case large = 24         // 大间距
        case extraLarge = 32    // 超大间距
        case huge = 48          // 巨大间距
        
        /// 根据设备类型调整间距
        @MainActor
        var adaptive: CGFloat {
            let baseValue = self.rawValue
            let screenWidth = UIScreen.main.bounds.width
            
            // iPad 使用更大的间距
            if UIDevice.current.userInterfaceIdiom == .pad {
                return baseValue * 1.25
            }
            
            // 小屏幕设备使用稍小的间距
            if screenWidth <= 375 {
                return max(baseValue * 0.875, 4)
            }
            
            return baseValue
        }
    }
    
    // MARK: - Safe Area Helpers
    
    /// 获取安全区域边距
    /// - Parameter view: 目标视图
    /// - Returns: 安全区域边距
    static func safeAreaInsets(for view: UIView) -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    /// 获取安全区域锚点
    /// - Parameter view: 目标视图
    /// - Returns: 安全区域布局指南
    static func safeAreaLayoutGuide(for view: UIView) -> UILayoutGuide {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide
        } else {
            return view.layoutMarginsGuide
        }
    }
    
    // MARK: - Constraint Activation Helpers
    
    /// 激活一组约束
    /// - Parameter constraints: 约束数组
    static func activate(_ constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.activate(constraints)
    }
    
    /// 激活一个约束
    /// - Parameter constraint: 约束
    static func activate(_ constraint: NSLayoutConstraint) {
        constraint.isActive = true
    }
    
    // MARK: - Priority Helpers
    
    /// 设置约束优先级
    /// - Parameters:
    ///   - constraint: 约束
    ///   - priority: 优先级
    /// - Returns: 设置了优先级的约束
    @discardableResult
    static func priority(_ constraint: NSLayoutConstraint, _ priority: UILayoutPriority) -> NSLayoutConstraint {
        constraint.priority = priority
        return constraint
    }
    
    // MARK: - Content Hugging & Compression Resistance
    
    /// 设置内容拥抱优先级
    /// - Parameters:
    ///   - view: 视图
    ///   - priority: 优先级
    ///   - axis: 轴向
    static func setContentHugging(_ view: UIView, priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) {
        view.setContentHuggingPriority(priority, for: axis)
    }
    
    /// 设置内容压缩阻力优先级
    /// - Parameters:
    ///   - view: 视图
    ///   - priority: 优先级
    ///   - axis: 轴向
    static func setContentCompressionResistance(_ view: UIView, priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) {
        view.setContentCompressionResistancePriority(priority, for: axis)
    }
    
    // MARK: - Stack View Helpers
    
    /// 创建垂直堆栈视图
    /// - Parameters:
    ///   - views: 子视图数组
    ///   - spacing: 间距
    ///   - alignment: 对齐方式
    ///   - distribution: 分布方式
    /// - Returns: 配置好的堆栈视图
    @MainActor
    static func verticalStack(
        views: [UIView],
        spacing: Spacing = .medium,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.spacing = spacing.adaptive
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    /// 创建水平堆栈视图
    /// - Parameters:
    ///   - views: 子视图数组
    ///   - spacing: 间距
    ///   - alignment: 对齐方式
    ///   - distribution: 分布方式
    /// - Returns: 配置好的堆栈视图
    @MainActor
    static func horizontalStack(
        views: [UIView],
        spacing: Spacing = .medium,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .horizontal
        stackView.spacing = spacing.adaptive
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    // MARK: - Size Constraints
    
    /// 设置固定尺寸
    /// - Parameters:
    ///   - view: 视图
    ///   - size: 尺寸
    /// - Returns: 约束数组
    @discardableResult
    static func size(_ view: UIView, _ size: CGSize) -> [NSLayoutConstraint] {
        let constraints = [
            view.widthAnchor.constraint(equalToConstant: size.width),
            view.heightAnchor.constraint(equalToConstant: size.height)
        ]
        activate(constraints)
        return constraints
    }
    
    /// 设置固定宽度
    /// - Parameters:
    ///   - view: 视图
    ///   - width: 宽度
    /// - Returns: 约束
    @discardableResult
    static func width(_ view: UIView, _ width: CGFloat) -> NSLayoutConstraint {
        let constraint = view.widthAnchor.constraint(equalToConstant: width)
        activate(constraint)
        return constraint
    }
    
    /// 设置固定高度
    /// - Parameters:
    ///   - view: 视图
    ///   - height: 高度
    /// - Returns: 约束
    @discardableResult
    static func height(_ view: UIView, _ height: CGFloat) -> NSLayoutConstraint {
        let constraint = view.heightAnchor.constraint(equalToConstant: height)
        activate(constraint)
        return constraint
    }
    
    /// 设置最小尺寸
    /// - Parameters:
    ///   - view: 视图
    ///   - size: 最小尺寸
    /// - Returns: 约束数组
    @discardableResult
    static func minimumSize(_ view: UIView, _ size: CGSize) -> [NSLayoutConstraint] {
        let constraints = [
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: size.width),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: size.height)
        ]
        activate(constraints)
        return constraints
    }
    
    /// 设置宽高比
    /// - Parameters:
    ///   - view: 视图
    ///   - ratio: 宽高比
    /// - Returns: 约束
    @discardableResult
    static func aspectRatio(_ view: UIView, _ ratio: CGFloat) -> NSLayoutConstraint {
        let constraint = view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: ratio)
        activate(constraint)
        return constraint
    }
}

// MARK: - UIView Layout Extensions

extension UIView {
    
    /// 准备约束布局
    /// - Returns: 自身，支持链式调用
    @discardableResult
    func prepareForConstraints() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    // MARK: - Fill Methods
    
    /// 填满父视图
    /// - Parameters:
    ///   - superview: 父视图（可选，默认使用当前父视图）
    ///   - insets: 边距
    /// - Returns: 约束数组
    @discardableResult
    func fillSuperview(
        _ superview: UIView? = nil,
        insets: UIEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        guard let parentView = superview ?? self.superview else {
            fatalError("Superview is required")
        }
        
        prepareForConstraints()
        let constraints = [
            topAnchor.constraint(equalTo: parentView.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -insets.bottom)
        ]
        LayoutHelper.activate(constraints)
        return constraints
    }
    
    /// 填满安全区域
    /// - Parameters:
    ///   - superview: 父视图（可选，默认使用当前父视图）
    ///   - insets: 额外边距
    /// - Returns: 约束数组
    @discardableResult
    func fillSafeArea(
        _ superview: UIView? = nil,
        insets: UIEdgeInsets = .zero
    ) -> [NSLayoutConstraint] {
        guard let parentView = superview ?? self.superview else {
            fatalError("Superview is required")
        }
        
        prepareForConstraints()
        let safeArea = LayoutHelper.safeAreaLayoutGuide(for: parentView)
        
        let constraints = [
            topAnchor.constraint(equalTo: safeArea.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -insets.bottom)
        ]
        LayoutHelper.activate(constraints)
        return constraints
    }
    
    // MARK: - Center Methods
    
    /// 在父视图中居中
    /// - Parameters:
    ///   - superview: 父视图（可选，默认使用当前父视图）
    ///   - offset: 偏移量
    /// - Returns: 约束数组
    @discardableResult
    func centerInSuperview(
        _ superview: UIView? = nil,
        offset: CGPoint = .zero
    ) -> [NSLayoutConstraint] {
        guard let parentView = superview ?? self.superview else {
            fatalError("Superview is required")
        }
        
        prepareForConstraints()
        let constraints = [
            centerXAnchor.constraint(equalTo: parentView.centerXAnchor, constant: offset.x),
            centerYAnchor.constraint(equalTo: parentView.centerYAnchor, constant: offset.y)
        ]
        LayoutHelper.activate(constraints)
        return constraints
    }
    
    /// 在安全区域中居中
    /// - Parameters:
    ///   - superview: 父视图（可选，默认使用当前父视图）
    ///   - offset: 偏移量
    /// - Returns: 约束数组
    @discardableResult
    func centerInSafeArea(
        _ superview: UIView? = nil,
        offset: CGPoint = .zero
    ) -> [NSLayoutConstraint] {
        guard let parentView = superview ?? self.superview else {
            fatalError("Superview is required")
        }
        
        prepareForConstraints()
        let safeArea = LayoutHelper.safeAreaLayoutGuide(for: parentView)
        
        let constraints = [
            centerXAnchor.constraint(equalTo: safeArea.centerXAnchor, constant: offset.x),
            centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: offset.y)
        ]
        LayoutHelper.activate(constraints)
        return constraints
    }
    
    // MARK: - Edge Methods
    
    /// 约束到顶部
    /// - Parameters:
    ///   - anchor: 目标锚点
    ///   - spacing: 间距
    ///   - relation: 约束关系
    /// - Returns: 约束
    @discardableResult
    @MainActor
    func constrainTop(
        to anchor: NSLayoutYAxisAnchor,
        spacing: LayoutHelper.Spacing = .none,
        relation: NSLayoutConstraint.Relation = .equal
    ) -> NSLayoutConstraint {
        prepareForConstraints()
        let constraint: NSLayoutConstraint
        
        switch relation {
        case .equal:
            constraint = topAnchor.constraint(equalTo: anchor, constant: spacing.adaptive)
        case .greaterThanOrEqual:
            constraint = topAnchor.constraint(greaterThanOrEqualTo: anchor, constant: spacing.adaptive)
        case .lessThanOrEqual:
            constraint = topAnchor.constraint(lessThanOrEqualTo: anchor, constant: spacing.adaptive)
        @unknown default:
            constraint = topAnchor.constraint(equalTo: anchor, constant: spacing.adaptive)
        }
        
        LayoutHelper.activate(constraint)
        return constraint
    }
    
    /// 约束到底部
    /// - Parameters:
    ///   - anchor: 目标锚点
    ///   - spacing: 间距
    ///   - relation: 约束关系
    /// - Returns: 约束
    @discardableResult
    @MainActor
    func constrainBottom(
        to anchor: NSLayoutYAxisAnchor,
        spacing: LayoutHelper.Spacing = .none,
        relation: NSLayoutConstraint.Relation = .equal
    ) -> NSLayoutConstraint {
        prepareForConstraints()
        let constraint: NSLayoutConstraint
        let actualSpacing = -spacing.adaptive // 底部间距为负值
        
        switch relation {
        case .equal:
            constraint = bottomAnchor.constraint(equalTo: anchor, constant: actualSpacing)
        case .greaterThanOrEqual:
            constraint = bottomAnchor.constraint(greaterThanOrEqualTo: anchor, constant: actualSpacing)
        case .lessThanOrEqual:
            constraint = bottomAnchor.constraint(lessThanOrEqualTo: anchor, constant: actualSpacing)
        @unknown default:
            constraint = bottomAnchor.constraint(equalTo: anchor, constant: actualSpacing)
        }
        
        LayoutHelper.activate(constraint)
        return constraint
    }
    
    /// 约束到左侧
    /// - Parameters:
    ///   - anchor: 目标锚点
    ///   - spacing: 间距
    ///   - relation: 约束关系
    /// - Returns: 约束
    @discardableResult
    @MainActor
    func constrainLeading(
        to anchor: NSLayoutXAxisAnchor,
        spacing: LayoutHelper.Spacing = .none,
        relation: NSLayoutConstraint.Relation = .equal
    ) -> NSLayoutConstraint {
        prepareForConstraints()
        let constraint: NSLayoutConstraint
        
        switch relation {
        case .equal:
            constraint = leadingAnchor.constraint(equalTo: anchor, constant: spacing.adaptive)
        case .greaterThanOrEqual:
            constraint = leadingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: spacing.adaptive)
        case .lessThanOrEqual:
            constraint = leadingAnchor.constraint(lessThanOrEqualTo: anchor, constant: spacing.adaptive)
        @unknown default:
            constraint = leadingAnchor.constraint(equalTo: anchor, constant: spacing.adaptive)
        }
        
        LayoutHelper.activate(constraint)
        return constraint
    }
    
    /// 约束到右侧
    /// - Parameters:
    ///   - anchor: 目标锚点
    ///   - spacing: 间距
    ///   - relation: 约束关系
    /// - Returns: 约束
    @discardableResult
    @MainActor
    func constrainTrailing(
        to anchor: NSLayoutXAxisAnchor,
        spacing: LayoutHelper.Spacing = .none,
        relation: NSLayoutConstraint.Relation = .equal
    ) -> NSLayoutConstraint {
        prepareForConstraints()
        let constraint: NSLayoutConstraint
        let actualSpacing = -spacing.adaptive // 右侧间距为负值
        
        switch relation {
        case .equal:
            constraint = trailingAnchor.constraint(equalTo: anchor, constant: actualSpacing)
        case .greaterThanOrEqual:
            constraint = trailingAnchor.constraint(greaterThanOrEqualTo: anchor, constant: actualSpacing)
        case .lessThanOrEqual:
            constraint = trailingAnchor.constraint(lessThanOrEqualTo: anchor, constant: actualSpacing)
        @unknown default:
            constraint = trailingAnchor.constraint(equalTo: anchor, constant: actualSpacing)
        }
        
        LayoutHelper.activate(constraint)
        return constraint
    }
    
    // MARK: - Size Methods
    
    /// 设置固定尺寸
    /// - Parameter size: 尺寸
    /// - Returns: 约束数组
    @discardableResult
    func constrainSize(_ size: CGSize) -> [NSLayoutConstraint] {
        return LayoutHelper.size(self, size)
    }
    
    /// 设置固定宽度
    /// - Parameter width: 宽度
    /// - Returns: 约束
    @discardableResult
    func constrainWidth(_ width: CGFloat) -> NSLayoutConstraint {
        return LayoutHelper.width(self, width)
    }
    
    /// 设置固定高度
    /// - Parameter height: 高度
    /// - Returns: 约束
    @discardableResult
    func constrainHeight(_ height: CGFloat) -> NSLayoutConstraint {
        return LayoutHelper.height(self, height)
    }
    
    /// 设置最小尺寸
    /// - Parameter size: 最小尺寸
    /// - Returns: 约束数组
    @discardableResult
    func constrainMinimumSize(_ size: CGSize) -> [NSLayoutConstraint] {
        return LayoutHelper.minimumSize(self, size)
    }
    
    /// 设置宽高比
    /// - Parameter ratio: 宽高比
    /// - Returns: 约束
    @discardableResult
    func constrainAspectRatio(_ ratio: CGFloat) -> NSLayoutConstraint {
        return LayoutHelper.aspectRatio(self, ratio)
    }
}

// MARK: - UIStackView Extensions

extension UIStackView {
    
    /// 添加间隔视图
    /// - Parameter spacing: 间隔大小
    @MainActor
    func addCustomSpacing(_ spacing: LayoutHelper.Spacing) {
        self.setCustomSpacing(spacing.adaptive, after: arrangedSubviews.last!)
    }
    
    /// 添加视图并设置间隔
    /// - Parameters:
    ///   - view: 要添加的视图
    ///   - spacing: 间隔大小
    @MainActor
    func addArrangedSubview(_ view: UIView, spacing: LayoutHelper.Spacing) {
        addArrangedSubview(view)
        if arrangedSubviews.count > 1 {
            setCustomSpacing(spacing.adaptive, after: arrangedSubviews[arrangedSubviews.count - 2])
        }
    }
}

// MARK: - UIEdgeInsets Extensions

extension UIEdgeInsets {
    
    /// 使用统一间距创建边距
    /// - Parameter spacing: 间距
    /// - Returns: 边距
    @MainActor
    static func all(_ spacing: LayoutHelper.Spacing) -> UIEdgeInsets {
        let value = spacing.adaptive
        return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
    
    /// 使用水平和垂直间距创建边距
    /// - Parameters:
    ///   - horizontal: 水平间距
    ///   - vertical: 垂直间距
    /// - Returns: 边距
    @MainActor
    static func symmetric(horizontal: LayoutHelper.Spacing, vertical: LayoutHelper.Spacing) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: vertical.adaptive,
            left: horizontal.adaptive,
            bottom: vertical.adaptive,
            right: horizontal.adaptive
        )
    }
    
    /// 只设置水平边距
    /// - Parameter spacing: 水平间距
    /// - Returns: 边距
    @MainActor
    static func horizontal(_ spacing: LayoutHelper.Spacing) -> UIEdgeInsets {
        let value = spacing.adaptive
        return UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
    }
    
    /// 只设置垂直边距
    /// - Parameter spacing: 垂直间距
    /// - Returns: 边距
    @MainActor
    static func vertical(_ spacing: LayoutHelper.Spacing) -> UIEdgeInsets {
        let value = spacing.adaptive
        return UIEdgeInsets(top: value, left: 0, bottom: value, right: 0)
    }
}
