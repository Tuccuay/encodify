//
//  MainTabBarController.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 主要的 TabBar 控制器，负责管理应用的主界面结构
class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupViewControllers()
    }
    
    // MARK: - Setup Methods
    
    private func setupTabBarAppearance() {
        // Modern TabBar configuration with enhanced styling
        tabBar.tintColor = UIColor.encodifyTintColor
    }
    
    private func setupViewControllers() {
        
        let encodeViewController = createEncodeModule()
        
        let hashViewController = createHashModule()
        
        let utilitiesViewController = createUtilitiesModule()
        
        // 设置所有视图控制器
        viewControllers = [
            encodeViewController,
            hashViewController,
            utilitiesViewController
        ]
    }
    
    // MARK: - Module Creation Methods
    
    private func createEncodeModule() -> UINavigationController {
        let encodeViewController = UnifiedEncodeViewController()
        encodeViewController.title = "Encode"
        
        let navigationController = UINavigationController(rootViewController: encodeViewController)
        navigationController.tabBarItem.title = "Encode"
        
        // 使用 SF Symbol: 编码转换图标 - 更简洁现代
        // 选择 textformat 图标，代表文本处理功能
        if let encodeImage = UIImage(systemName: "chevron.left.forwardslash.chevron.right") {
            let configuredImage = encodeImage.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .medium)
            )
            navigationController.tabBarItem.image = configuredImage
        }
        
        return navigationController
    }
    
    private func createHashModule() -> UINavigationController {
        let hashViewController = ModernHashViewController()
        hashViewController.title = "Hash"
        
        let navigationController = UINavigationController(rootViewController: hashViewController)
        navigationController.tabBarItem.title = "Hash"
        
        // 使用 SF Symbol: 哈希/加密相关的图标
        // 选择 number.square 图标，更简洁现代
        if let hashImage = UIImage(systemName: "number.square") {
            let configuredImage = hashImage.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .medium)
            )
            navigationController.tabBarItem.image = configuredImage
        }
        
        return navigationController
    }
    
    private func createUtilitiesModule() -> UINavigationController {
        let utilitiesViewController = UtilitiesViewController()
        utilitiesViewController.title = "Utilities"
        
        let navigationController = UINavigationController(rootViewController: utilitiesViewController)
        navigationController.tabBarItem.title = "Utilities"
        
        // 使用 SF Symbol: 工具图标 - 更简洁
        if let utilitiesImage = UIImage(systemName: "wrench.and.screwdriver") {
            let configuredImage = utilitiesImage.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .medium)
            )
            navigationController.tabBarItem.image = configuredImage
        }
        
        return navigationController
    }
}

// MARK: - Factory Methods

extension MainTabBarController {
    
    /// 创建并返回配置好的主 TabBar 控制器
    /// - Returns: 配置好的 MainTabBarController 实例
    @MainActor
    static func create() -> MainTabBarController {
        return MainTabBarController()
    }
}
