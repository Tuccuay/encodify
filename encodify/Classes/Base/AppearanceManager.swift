//
//  AppearanceManager.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 管理应用全局外观配置的单例类
/// 负责配置现代化 iOS 应用的整体外观，包括导航栏、标签栏、控件等的样式
@MainActor
final class AppearanceManager {
    
    // MARK: - Singleton
    
    static let shared = AppearanceManager()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 配置应用的整体外观
    func configureAppearance() {
        configureNavigationBarAppearance()
        configureTabBarAppearance()
        configureControlAppearance()
        configureTextFieldAppearance()
        configureTableViewAppearance()
        configureCollectionViewAppearance()
        configureScrollViewAppearance()
        configureSystemIntegration()
    }
    
    // MARK: - Navigation Bar Configuration
    
    private func configureNavigationBarAppearance() {
        // 标准导航栏外观 (iOS 16.6+ 现代化设计)
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.backgroundColor = UIColor.systemBackground
        standardAppearance.shadowColor = UIColor.clear
        
        // 标题文字样式
        standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.encodifyPrimaryText,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        
        // 大标题文字样式
        standardAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.encodifyPrimaryText,
            .font: UIFont.preferredFont(forTextStyle: .largeTitle)
        ]
        
        // 按钮文字样式
        standardAppearance.buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.encodifyTintColor,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        
        standardAppearance.doneButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.encodifyTintColor,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ]
        
        // 紧凑导航栏外观
        let compactAppearance = standardAppearance.copy()
        
        // 滚动边缘外观
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        scrollEdgeAppearance.titleTextAttributes = standardAppearance.titleTextAttributes
        scrollEdgeAppearance.largeTitleTextAttributes = standardAppearance.largeTitleTextAttributes
        scrollEdgeAppearance.buttonAppearance = standardAppearance.buttonAppearance
        scrollEdgeAppearance.doneButtonAppearance = standardAppearance.doneButtonAppearance
        
        // 应用外观配置
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.standardAppearance = standardAppearance
        navigationBarAppearance.compactAppearance = compactAppearance
        navigationBarAppearance.scrollEdgeAppearance = scrollEdgeAppearance
        navigationBarAppearance.compactScrollEdgeAppearance = compactAppearance
        
        // 全局着色
        navigationBarAppearance.tintColor = UIColor.encodifyTintColor
        navigationBarAppearance.isTranslucent = true
    }
    
    // MARK: - Tab Bar Configuration
    
    private func configureTabBarAppearance() {
        // 标准标签栏外观
        let standardAppearance = UITabBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.backgroundColor = UIColor.systemBackground
        standardAppearance.shadowColor = UIColor.encodifyBorderColor.withAlphaComponent(0.3)
        
        // 标签项外观
        standardAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        standardAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.preferredFont(forTextStyle: .caption1)
        ]
        
        standardAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.encodifyTintColor
        standardAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.encodifyTintColor,
            .font: UIFont.preferredFont(forTextStyle: .caption1)
        ]
        
        // 内联布局外观（iPhone 横屏等）
        standardAppearance.inlineLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        standardAppearance.inlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        
        standardAppearance.inlineLayoutAppearance.selected.iconColor = UIColor.encodifyTintColor
        standardAppearance.inlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.encodifyTintColor,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        
        // 紧凑布局外观
        standardAppearance.compactInlineLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        standardAppearance.compactInlineLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ]
        
        standardAppearance.compactInlineLayoutAppearance.selected.iconColor = UIColor.encodifyTintColor
        standardAppearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.encodifyTintColor,
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ]
        
        // 应用外观配置
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.standardAppearance = standardAppearance
        tabBarAppearance.scrollEdgeAppearance = standardAppearance
        tabBarAppearance.tintColor = UIColor.encodifyTintColor
        tabBarAppearance.unselectedItemTintColor = UIColor.secondaryLabel
        tabBarAppearance.isTranslucent = true
    }
    
    // MARK: - Control Configuration
    
    private func configureControlAppearance() {
        // 通用控件着色
        UIControl.appearance().tintColor = UIColor.encodifyTintColor
        
        // 开关控件
        UISwitch.appearance().onTintColor = UIColor.encodifyTintColor
        UISwitch.appearance().thumbTintColor = UIColor.white
        
        // 步进器控件
        UIStepper.appearance().tintColor = UIColor.encodifyTintColor
        
        // 滑块控件
        UISlider.appearance().tintColor = UIColor.encodifyTintColor
        UISlider.appearance().thumbTintColor = UIColor.encodifyTintColor
        UISlider.appearance().minimumTrackTintColor = UIColor.encodifyTintColor
        UISlider.appearance().maximumTrackTintColor = UIColor.encodifyBorderColor
        
        // 进度条
        UIProgressView.appearance().tintColor = UIColor.encodifyTintColor
        UIProgressView.appearance().trackTintColor = UIColor.encodifyBorderColor
        
        // 分段控件
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.encodifyTintColor
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.encodifyPrimaryText,
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.preferredFont(forTextStyle: .callout)
        ], for: .selected)
    }
    
    // MARK: - System Integration
    
    private func configureSystemIntegration() {
        // 使用标准的动态字体监听，系统会自动处理深色模式
        configureDynamicTypeSupport()
    }
    
    // MARK: - Text Field Configuration
    
    private func configureTextFieldAppearance() {
        // 文本框全局样式
        UITextField.appearance().tintColor = UIColor.encodifyTintColor
        UITextField.appearance().textColor = UIColor.encodifyPrimaryText
        
        // 文本视图全局样式
        UITextView.appearance().tintColor = UIColor.encodifyTintColor
        UITextView.appearance().textColor = UIColor.encodifyPrimaryText
        
        // 搜索框样式
        UISearchBar.appearance().tintColor = UIColor.encodifyTintColor
        UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
    }
    
    // MARK: - Table View Configuration
    
    private func configureTableViewAppearance() {
        // 表格视图样式
        UITableView.appearance().tintColor = UIColor.encodifyTintColor
        UITableView.appearance().backgroundColor = UIColor.systemBackground
        UITableView.appearance().separatorColor = UIColor.encodifyBorderColor
        UITableView.appearance().sectionIndexColor = UIColor.encodifyTintColor
        UITableView.appearance().sectionIndexBackgroundColor = UIColor.clear
        
        // 表格单元格样式
        UITableViewCell.appearance().tintColor = UIColor.encodifyTintColor
        UITableViewCell.appearance().backgroundColor = UIColor.systemBackground
        UITableViewCell.appearance().selectionStyle = .none
    }
    
    // MARK: - Collection View Configuration
    
    private func configureCollectionViewAppearance() {
        // 集合视图样式
        UICollectionView.appearance().backgroundColor = UIColor.systemBackground
        UICollectionView.appearance().tintColor = UIColor.encodifyTintColor
    }
    
    // MARK: - Scroll View Configuration
    
    private func configureScrollViewAppearance() {
        // 滚动视图指示器样式
        UIScrollView.appearance().indicatorStyle = .default
        
        // 刷新控件样式
        UIRefreshControl.appearance().tintColor = UIColor.encodifyTintColor
    }
}

// MARK: - Dynamic Type Support

extension AppearanceManager {
    
    /// 配置动态字体支持
    func configureDynamicTypeSupport() {
        // 监听字体大小变化通知
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
    private func handleContentSizeCategoryChange() {
        // 重新配置外观以适应新的字体大小
        configureAppearance()
    }
}

// MARK: - Accessibility Support

extension AppearanceManager {
    
    /// 配置无障碍功能支持
    func configureAccessibilitySupport() {
        // 监听对比度变化
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleAccessibilityChange()
            }
        }
        
        // 监听减少透明度变化
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceTransparencyStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleAccessibilityChange()
            }
        }
    }
    
    @MainActor
    private func handleAccessibilityChange() {
        // 重新配置外观以适应无障碍设置
        configureAppearance()
    }
}
