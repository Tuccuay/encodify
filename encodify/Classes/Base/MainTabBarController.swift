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
        let encodePagerViewController = EncodePagerViewController()
        encodePagerViewController.title = "Encode"
        
        let navigationController = UINavigationController(rootViewController: encodePagerViewController)
        navigationController.tabBarItem.title = "Encode"
        
        // 使用 SF Symbol: 编码转换图标，更有活力 - 备选方案
        // 选项1: arrow.triangle.2.circlepath.circle - 双向循环转换
        // 选项2: function - 函数符号，代表转换处理
        // 选项3: chevron.left.forwardslash.chevron.right - 代码标签样式
        // 选项4: abc.dexia - 字母转换效果
        if let encodeImage = UIImage(systemName: "chevron.left.forwardslash.chevron.right") {
            // 配置适合 TabBar 的图标尺寸和样式
            let configuredImage = encodeImage.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 17, weight: .regular, scale: .medium)
            )
            navigationController.tabBarItem.image = configuredImage
        }
        
        return navigationController
    }
    
    private func createHashModule() -> UINavigationController {
        let hashViewController = HashViewController()
        hashViewController.title = "Hash"
        
        let navigationController = UINavigationController(rootViewController: hashViewController)
        navigationController.tabBarItem.title = "Hash"
        
        // 使用 SF Symbol: 哈希/加密相关的图标 - 多种选择
        // 选项1: checksum - 校验和图标，直接相关哈希计算 ⭐ 推荐
        // 选项2: lock.shield - 安全盾牌，体现加密安全性
        // 选项3: key.fill - 密钥图标，经典的加密象征  
        // 选项4: function - 数学函数符号 ƒ，体现算法处理
        // 选项5: seal.fill - 印章图标，体现验证和签名
        if let hashImage = UIImage(systemName: "number") {
            // 配置适合 TabBar 的图标尺寸和样式
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
        
        // 使用 SF Symbol: 工具图标
        if let utilitiesImage = UIImage(systemName: "wrench.and.screwdriver") {
            // 配置适合 TabBar 的图标尺寸和样式
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
