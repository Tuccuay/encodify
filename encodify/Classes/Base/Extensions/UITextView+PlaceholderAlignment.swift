//
//  UITextView+PlaceholderAlignment.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

// MARK: - 精确对齐方法

extension UITextView {
    
    /// 获取文本在 UITextView 中的实际渲染矩形
    /// 这比计算更准确，因为它使用了 UITextView 内部的布局信息
    func getActualTextRect() -> CGRect {
        guard let layoutManager = layoutManager,
              let textContainer = textContainer else {
            return .zero
        }
        
        // 获取文本的实际布局矩形
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let textRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        // 添加 contentInset 和 textContainerInset 的偏移
        return CGRect(
            x: textRect.origin.x + contentInset.left + textContainerInset.left,
            y: textRect.origin.y + contentInset.top + textContainerInset.top,
            width: textRect.width,
            height: textRect.height
        )
    }
    
    /// 使用精确方法更新 placeholder 位置
    func updatePlaceholderWithPreciseAlignment() {
        guard let label = placeholderLabel else { return }
        
        // 如果没有文本，使用一个示例字符来获取正确的基线位置
        let originalText = text
        let wasEmpty = text.isEmpty
        
        if wasEmpty {
            // 临时设置一个字符来获取正确的文本位置
            text = "A"
        }
        
        // 强制布局更新
        layoutIfNeeded()
        
        // 获取实际文本位置
        let actualTextRect = getActualTextRect()
        
        // 恢复原始文本
        if wasEmpty {
            text = originalText
        }
        
        // 更新约束以匹配实际文本位置
        updatePlaceholderConstraintsWithPrecisePosition(actualTextRect.origin)
        
        print("🎯 精确对齐结果:")
        print("   • 实际文本位置: \(actualTextRect.origin)")
        print("   • Placeholder 将调整到此位置")
    }
    
    private func updatePlaceholderConstraintsWithPrecisePosition(_ position: CGPoint) {
        guard let label = placeholderLabel else { return }
        
        // 移除现有约束
        label.removeFromSuperview()
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 使用精确位置设置约束，不需要额外的 textInsets
        label.textInsets = .zero // 清除内边距，使用精确约束
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: position.y),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: position.x),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -contentInset.right)
        ])
    }
}

// MARK: - 基线对齐方法

extension UITextView {
    
    /// 使用字体基线对齐方法
    func updatePlaceholderWithBaselineAlignment() {
        guard let label = placeholderLabel,
              let font = self.font else { return }
        
        // 计算字体的基线偏移
        let fontDescender = font.descender
        let fontAscender = font.ascender
        let lineHeight = font.lineHeight
        
        // UITextView 的第一行文本基线位置
        let textViewBaselineY = contentInset.top + textContainerInset.top + fontAscender
        
        // 设置 placeholder 的位置以匹配基线
        let placeholderY = textViewBaselineY - fontAscender
        let placeholderX = contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding
        
        // 更新约束
        label.removeFromSuperview()
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textInsets = .zero // 使用精确约束，不需要内边距
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: placeholderY),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: placeholderX),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -contentInset.right)
        ])
        
        print("📏 基线对齐结果:")
        print("   • 字体信息: ascender=\(fontAscender), descender=\(fontDescender), lineHeight=\(lineHeight)")
        print("   • 文本基线Y: \(textViewBaselineY)")
        print("   • Placeholder位置: x=\(placeholderX), y=\(placeholderY)")
    }
}

// MARK: - 实验性对齐方法

extension UITextView {
    
    /// 微调对齐 - 允许手动调整像素级偏移
    func adjustPlaceholderAlignment(xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        guard let label = placeholderLabel else { return }
        
        // 获取当前约束
        for constraint in constraints {
            if let firstItem = constraint.firstItem as? UILabel,
               firstItem == label {
                if constraint.firstAttribute == .leading {
                    constraint.constant += xOffset
                } else if constraint.firstAttribute == .top {
                    constraint.constant += yOffset
                }
            }
        }
        
        layoutIfNeeded()
        print("🔧 手动调整: x偏移=\(xOffset), y偏移=\(yOffset)")
    }
}
