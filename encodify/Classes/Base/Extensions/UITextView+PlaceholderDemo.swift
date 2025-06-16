//
//  UITextView+PlaceholderDemo.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit
import SnapKit

/// 演示统一 UITextView Placeholder 功能的视图控制器
class UITextViewPlaceholderDemoViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.contentInsetAdjustmentBehavior = .automatic
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UITextView Placeholder 统一实现演示"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = UIColor.encodifyPrimaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "此页面展示了新的统一 UITextView placeholder 扩展的使用方法。所有 placeholder 现在都使用相同的实现，具有一致的外观和行为。"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = UIColor.encodifySecondaryText
        label.textAlignment = .left
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    // 示例 1: 基础 placeholder
    private lazy var basicTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = UIColor.encodifyCardBackground
        textView.textColor = UIColor.encodifyPrimaryText
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = false
        textView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.applyThemeAwareShadow(radius: 4, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // 设置基础 placeholder
        textView.setPlaceholder("请输入基础文本...")
        
        return textView
    }()
    
    // 示例 2: 带样式的 placeholder
    private lazy var styledTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = UIColor.encodifyCardBackground
        textView.textColor = UIColor.encodifyPrimaryText
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = false
        textView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.applyThemeAwareShadow(radius: 4, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // 设置带样式的 placeholder
        textView.setPlaceholder("输入要编码的文本内容...", style: .inputPlaceholder)
        
        return textView
    }()
    
    // 示例 3: 自定义 placeholder
    private lazy var customTextView: UITextView = {
        let textView = UITextView()
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        textView.font = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
        textView.backgroundColor = UIColor.encodifyCardBackground
        textView.textColor = UIColor.encodifyPrimaryText
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = false
        textView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.applyThemeAwareShadow(radius: 4, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // 设置自定义颜色和字体的 placeholder
        textView.setPlaceholder(
            "粘贴 base64 编码的图片数据到这里...",
            color: UIColor.systemOrange,
            font: UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
        )
        
        return textView
    }()
    
    // 示例 4: 多行 placeholder
    private lazy var multilineTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = UIColor.encodifyCardBackground
        textView.textColor = UIColor.encodifyPrimaryText
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = false
        textView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.applyThemeAwareShadow(radius: 4, opacity: 0.1, offset: CGSize(width: 0, height: 2))
        
        // 设置多行 placeholder
        textView.setPlaceholder("这是一个支持多行显示的 placeholder 示例。它会自动换行并适应容器的宽度，提供更好的用户体验。你可以在这里输入较长的文本内容。")
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        title = "Placeholder Demo"
        view.backgroundColor = UIColor.systemBackground
        
        // 添加视图层次
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        // 添加示例标签和文本视图
        let exampleViews = [
            createExampleSection("基础 Placeholder", basicTextView),
            createExampleSection("带样式的 Placeholder", styledTextView),
            createExampleSection("自定义 Placeholder", customTextView),
            createExampleSection("多行 Placeholder", multilineTextView)
        ]
        
        exampleViews.forEach { contentView.addSubview($0) }
        
        // 存储示例视图用于约束设置
        self.exampleViews = exampleViews
    }
    
    private var exampleViews: [UIView] = []
    
    private func createExampleSection(_ title: String, _ textView: UITextView) -> UIView {
        let sectionView = UIView()
        sectionView.backgroundColor = UIColor.clear
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = UIColor.encodifyTintColor
        titleLabel.adjustsFontForContentSizeCategory = true
        
        sectionView.addSubview(titleLabel)
        sectionView.addSubview(textView)
        
        // 设置约束
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        
        return sectionView
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 设置示例视图的约束
        var previousView: UIView = descriptionLabel
        
        for exampleView in exampleViews {
            exampleView.snp.makeConstraints { make in
                make.top.equalTo(previousView.snp.bottom).offset(24)
                make.left.right.equalToSuperview().inset(20)
            }
            previousView = exampleView
        }
        
        // 设置内容视图的底部约束
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(previousView.snp.bottom).offset(20)
        }
    }
}

// MARK: - 使用说明注释

/*
 
 ## UITextView Placeholder 统一实现说明
 
 ### 主要特性：
 1. **统一的 API**: 所有 UITextView 都使用相同的方法设置 placeholder
 2. **自动布局**: placeholder 会自动适应 textView 的内边距和文本容器设置
 3. **主题支持**: 自动适应应用的主题颜色
 4. **字体同步**: placeholder 字体会跟随 textView 的字体变化
 5. **内存安全**: 使用 Associated Objects 安全地存储属性
 
 ### 使用方法：
 
 #### 1. 基础用法
 ```swift
 textView.setPlaceholder("请输入文本...")
 ```
 
 #### 2. 带样式
 ```swift
 textView.setPlaceholder("请输入文本...", style: .inputPlaceholder)
 ```
 
 #### 3. 自定义颜色和字体
 ```swift
 textView.setPlaceholder(
     "请输入文本...",
     color: UIColor.gray,
     font: UIFont.systemFont(ofSize: 16)
 )
 ```
 
 #### 4. 主题更新
 ```swift
 textView.applyThemeToPlaceholder()
 ```
 
 #### 5. 移除 placeholder
 ```swift
 textView.removePlaceholder()
 ```
 
 ### 替代的旧实现：
 
 #### 原先的文本模拟方式 (EncodeBaseViewController)
 - 通过修改 textView.text 和 textColor 来模拟 placeholder
 - 需要手动处理 delegate 方法
 - 容易出现逻辑错误
 
 #### 原先的独立 Label 方式 (HashViewController, ImageDecodeViewController)
 - 需要手动创建和管理 UILabel
 - 需要手动设置约束和布局
 - 需要手动处理显示/隐藏逻辑
 - 需要手动处理主题更新
 
 ### 迁移指南：
 
 1. 移除旧的 placeholder 相关代码
 2. 使用新的 `setPlaceholder()` 方法
 3. 移除 UITextViewDelegate 中的 placeholder 处理逻辑
 4. 在主题更新时调用 `applyThemeToPlaceholder()`
 
 */
