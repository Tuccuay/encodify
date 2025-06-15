//
//  AnimationHelper.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 动画辅助工具
/// 提供现代化的UI动画效果，遵循 iOS 16.6+ 设计规范
@MainActor
struct AnimationHelper {
    
    // MARK: - Animation Presets
    
    /// 动画预设类型
    enum Preset {
        case gentle         // 温和动画 - 日常交互
        case bouncy         // 弹性动画 - 吸引注意
        case sharp          // 锐利动画 - 快速响应
        case smooth         // 平滑动画 - 优雅过渡
        
        var duration: TimeInterval {
            switch self {
            case .gentle: return 0.3
            case .bouncy: return 0.6
            case .sharp: return 0.2
            case .smooth: return 0.4
            }
        }
        
        var damping: CGFloat {
            switch self {
            case .gentle: return 0.8
            case .bouncy: return 0.6
            case .sharp: return 1.0
            case .smooth: return 0.9
            }
        }
        
        var velocity: CGFloat {
            switch self {
            case .gentle: return 0.5
            case .bouncy: return 0.8
            case .sharp: return 1.2
            case .smooth: return 0.3
            }
        }
    }
    
    // MARK: - Common Animations
    
    /// 淡入动画
    /// - Parameters:
    ///   - view: 要动画的视图
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    @MainActor
    static func fadeIn(
        _ view: UIView,
        preset: Preset = .gentle,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        view.alpha = 0
        UIView.animate(
            withDuration: preset.duration,
            delay: delay,
            usingSpringWithDamping: preset.damping,
            initialSpringVelocity: preset.velocity,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            view.alpha = 1
        } completion: { _ in
            completion?()
        }
    }
    
    /// 淡出动画
    /// - Parameters:
    ///   - view: 要动画的视图
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    @MainActor
    static func fadeOut(
        _ view: UIView,
        preset: Preset = .gentle,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: preset.duration,
            delay: delay,
            usingSpringWithDamping: preset.damping,
            initialSpringVelocity: preset.velocity,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            view.alpha = 0
        } completion: { _ in
            completion?()
        }
    }
    
    /// 缩放动画
    /// - Parameters:
    ///   - view: 要动画的视图
    ///   - fromScale: 起始缩放比例
    ///   - toScale: 结束缩放比例
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    @MainActor
    static func scale(
        _ view: UIView,
        from fromScale: CGFloat,
        to toScale: CGFloat,
        preset: Preset = .gentle,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        view.transform = CGAffineTransform(scaleX: fromScale, y: fromScale)
        UIView.animate(
            withDuration: preset.duration,
            delay: delay,
            usingSpringWithDamping: preset.damping,
            initialSpringVelocity: preset.velocity,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            view.transform = CGAffineTransform(scaleX: toScale, y: toScale)
        } completion: { _ in
            completion?()
        }
    }
    
    /// 滑动动画
    /// - Parameters:
    ///   - view: 要动画的视图
    ///   - direction: 滑动方向
    ///   - distance: 滑动距离（可选，默认使用视图宽度/高度）
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    @MainActor
    static func slide(
        _ view: UIView,
        direction: SlideDirection,
        distance: CGFloat? = nil,
        preset: Preset = .gentle,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        let actualDistance = distance ?? (direction.isHorizontal ? view.frame.width : view.frame.height)
        let initialTransform = direction.initialTransform(distance: actualDistance)
        
        view.transform = initialTransform
        UIView.animate(
            withDuration: preset.duration,
            delay: delay,
            usingSpringWithDamping: preset.damping,
            initialSpringVelocity: preset.velocity,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }
    
    /// 组合动画（淡入 + 缩放）
    /// - Parameters:
    ///   - view: 要动画的视图
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    @MainActor
    static func popIn(
        _ view: UIView,
        preset: Preset = .bouncy,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(
            withDuration: preset.duration,
            delay: delay,
            usingSpringWithDamping: preset.damping,
            initialSpringVelocity: preset.velocity,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            view.alpha = 1
            view.transform = .identity
        } completion: { _ in
            completion?()
        }
    }
    
    /// 组合动画（淡出 + 缩放）
    /// - Parameters:
    ///   - view: 要动画的视图
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    @MainActor
    static func popOut(
        _ view: UIView,
        preset: Preset = .sharp,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: preset.duration,
            delay: delay,
            usingSpringWithDamping: preset.damping,
            initialSpringVelocity: preset.velocity,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            completion?()
        }
    }
    
    // MARK: - Interactive Animations
    
    /// 按钮按下动画
    /// - Parameter button: 按钮
    @MainActor
    static func buttonTouchDown(_ button: UIButton) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            button.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            button.alpha = 0.8
        }
    }
    
    /// 按钮释放动画
    /// - Parameter button: 按钮
    @MainActor
    static func buttonTouchUp(_ button: UIButton) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.6,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            button.transform = .identity
            button.alpha = 1.0
        }
    }
    
    /// 卡片悬停动画
    /// - Parameters:
    ///   - view: 卡片视图
    ///   - isHovered: 是否悬停
    @MainActor
    static func cardHover(_ view: UIView, isHovered: Bool) {
        let scale: CGFloat = isHovered ? 1.02 : 1.0
        let shadowOpacity: Float = isHovered ? 0.15 : 0.08
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            view.transform = CGAffineTransform(scaleX: scale, y: scale)
            view.layer.shadowOpacity = shadowOpacity
        }
    }
    
    // MARK: - Collection Animations
    
    /// 顺序动画多个视图
    /// - Parameters:
    ///   - views: 视图数组
    ///   - animation: 动画闭包
    ///   - stagger: 每个视图之间的延迟
    ///   - completion: 完成回调
    @MainActor
    static func staggeredAnimation(
        views: [UIView],
        animation: @escaping (UIView, TimeInterval, @escaping () -> Void) -> Void,
        stagger: TimeInterval = 0.1,
        completion: (() -> Void)? = nil
    ) {
        var completedCount = 0
        let totalCount = views.count
        
        for (index, view) in views.enumerated() {
            let delay = TimeInterval(index) * stagger
            
            animation(view, delay) {
                completedCount += 1
                if completedCount == totalCount {
                    completion?()
                }
            }
        }
    }
    
    // MARK: - Transition Animations
    
    /// 视图过渡动画
    /// - Parameters:
    ///   - fromView: 起始视图
    ///   - toView: 目标视图
    ///   - transition: 过渡类型
    ///   - duration: 动画时长
    ///   - completion: 完成回调
    @MainActor
    static func transition(
        from fromView: UIView,
        to toView: UIView,
        transition: TransitionType,
        duration: TimeInterval = 0.3,
        completion: (() -> Void)? = nil
    ) {
        guard let containerView = fromView.superview else { return }
        
        // 设置初始状态
        transition.prepareViews(from: fromView, to: toView, in: containerView)
        
        // 执行动画
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: [.allowUserInteraction, .curveEaseOut]
        ) {
            transition.animateTransition(from: fromView, to: toView)
        } completion: { _ in
            transition.cleanupViews(from: fromView, to: toView)
            completion?()
        }
    }
}

// MARK: - Supporting Types

extension AnimationHelper {
    
    /// 滑动方向
    enum SlideDirection {
        case up
        case down
        case left
        case right
        
        var isHorizontal: Bool {
            return self == .left || self == .right
        }
        
        func initialTransform(distance: CGFloat) -> CGAffineTransform {
            switch self {
            case .up:
                return CGAffineTransform(translationX: 0, y: distance)
            case .down:
                return CGAffineTransform(translationX: 0, y: -distance)
            case .left:
                return CGAffineTransform(translationX: distance, y: 0)
            case .right:
                return CGAffineTransform(translationX: -distance, y: 0)
            }
        }
    }
    
    /// 过渡类型
    enum TransitionType {
        case fade
        case slide(SlideDirection)
        case push(SlideDirection)
        case zoom
        
        @MainActor
        func prepareViews(from fromView: UIView, to toView: UIView, in containerView: UIView) {
            containerView.addSubview(toView)
            toView.frame = fromView.frame
            
            switch self {
            case .fade:
                toView.alpha = 0
            case .slide(let direction):
                let distance = direction.isHorizontal ? containerView.frame.width : containerView.frame.height
                toView.transform = direction.initialTransform(distance: distance)
            case .push(let direction):
                let distance = direction.isHorizontal ? containerView.frame.width : containerView.frame.height
                toView.transform = direction.initialTransform(distance: distance)
            case .zoom:
                toView.alpha = 0
                toView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        
        @MainActor
        func animateTransition(from fromView: UIView, to toView: UIView) {
            switch self {
            case .fade:
                fromView.alpha = 0
                toView.alpha = 1
            case .slide(let direction):
                let distance = direction.isHorizontal ? fromView.frame.width : fromView.frame.height
                fromView.transform = direction.initialTransform(distance: -distance)
                toView.transform = .identity
            case .push(let direction):
                let distance = direction.isHorizontal ? fromView.frame.width : fromView.frame.height
                fromView.transform = direction.initialTransform(distance: -distance)
                toView.transform = .identity
            case .zoom:
                fromView.alpha = 0
                fromView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                toView.alpha = 1
                toView.transform = .identity
            }
        }
        
        @MainActor
        func cleanupViews(from fromView: UIView, to toView: UIView) {
            fromView.removeFromSuperview()
            fromView.alpha = 1
            fromView.transform = .identity
        }
    }
}

// MARK: - UIView Animation Extensions

extension UIView {
    
    /// 快速淡入
    /// - Parameters:
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    func fadeIn(preset: AnimationHelper.Preset = .gentle, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        AnimationHelper.fadeIn(self, preset: preset, delay: delay, completion: completion)
    }
    
    /// 快速淡出
    /// - Parameters:
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    func fadeOut(preset: AnimationHelper.Preset = .gentle, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        AnimationHelper.fadeOut(self, preset: preset, delay: delay, completion: completion)
    }
    
    /// 快速弹入
    /// - Parameters:
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    func popIn(preset: AnimationHelper.Preset = .bouncy, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        AnimationHelper.popIn(self, preset: preset, delay: delay, completion: completion)
    }
    
    /// 快速弹出
    /// - Parameters:
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    func popOut(preset: AnimationHelper.Preset = .sharp, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        AnimationHelper.popOut(self, preset: preset, delay: delay, completion: completion)
    }
    
    /// 快速滑动
    /// - Parameters:
    ///   - direction: 滑动方向
    ///   - distance: 滑动距离
    ///   - preset: 动画预设
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    func slideIn(
        direction: AnimationHelper.SlideDirection,
        distance: CGFloat? = nil,
        preset: AnimationHelper.Preset = .gentle,
        delay: TimeInterval = 0,
        completion: (() -> Void)? = nil
    ) {
        AnimationHelper.slide(self, direction: direction, distance: distance, preset: preset, delay: delay, completion: completion)
    }
}
