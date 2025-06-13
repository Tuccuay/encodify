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
        // 配置 TabBar 外观
        tabBar.tintColor = UIColor.encodifyTintColor
    }
    
    private func setupViewControllers() {
        print("🔄 开始创建视图控制器...")
        
        // 先创建一个简单的测试视图控制器
        let testViewController = UIViewController()
        testViewController.view.backgroundColor = .systemBlue
        testViewController.title = "Test"
        
        let testNavController = UINavigationController(rootViewController: testViewController)
        testNavController.tabBarItem.title = "Test"
        testNavController.tabBarItem.image = UIImage(systemName: "gear")
        
        print("✅ 测试视图控制器创建成功")
        
        // 尝试创建真实的视图控制器
        do {
            let encodeViewController = createEncodeModule()
            print("✅ Encode 模块创建成功")
            
            let hashViewController = createHashModule()
            print("✅ Hash 模块创建成功")
            
            let utilitiesViewController = createUtilitiesModule()
            print("✅ Utilities 模块创建成功")
            
            // 设置所有视图控制器
            viewControllers = [
                encodeViewController,
                hashViewController,
                utilitiesViewController
            ]
            print("✅ 所有视图控制器设置完成")
        } catch {
            print("❌ 创建视图控制器时出错: \(error)")
            // 如果出错，使用测试视图控制器
            viewControllers = [testNavController]
        }
    }
    
    // MARK: - Module Creation Methods
    
    private func createEncodeModule() -> UINavigationController {
        let encodePagerViewController = EncodePagerViewController()
        encodePagerViewController.title = "Encode"
        
        let navigationController = UINavigationController(rootViewController: encodePagerViewController)
        navigationController.tabBarItem.title = "Encode"
        navigationController.tabBarItem.image = UIImage(named: "encode")
        
        return navigationController
    }
    
    private func createHashModule() -> UINavigationController {
        let hashViewController = HashViewController()
        hashViewController.title = "Hash"
        
        let navigationController = UINavigationController(rootViewController: hashViewController)
        navigationController.tabBarItem.title = "Hash"
        navigationController.tabBarItem.image = UIImage(named: "hash")
        
        return navigationController
    }
    
    private func createUtilitiesModule() -> UINavigationController {
        let utilitiesViewController = UtilitiesViewController()
        utilitiesViewController.title = "Utilities"
        
        let navigationController = UINavigationController(rootViewController: utilitiesViewController)
        navigationController.tabBarItem.title = "Utilities"
        navigationController.tabBarItem.image = UIImage(named: "Utilities")
        
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
