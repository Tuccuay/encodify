//
//  AppCoordinator.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

/// 应用程序协调器，负责管理应用的整体导航流程
@MainActor
class AppCoordinator {
    
    private weak var window: UIWindow?
    private var mainTabBarController: MainTabBarController?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    /// 启动应用程序的主流程
    func start() {
        setupMainInterface()
    }
    
    // MARK: - Private Methods
    
    private func setupMainInterface() {

        mainTabBarController = MainTabBarController.create()

        
        window?.rootViewController = mainTabBarController

        
        window?.makeKeyAndVisible()


    }
    
    // MARK: - Public Interface
    
    /// 切换到指定的 Tab
    /// - Parameter index: Tab 索引 (0: Encode, 1: Hash, 2: Utilities)
    func switchToTab(at index: Int) {
        mainTabBarController?.selectedIndex = index
    }
    
    /// 获取当前选中的 Tab 索引
    var currentTabIndex: Int {
        return mainTabBarController?.selectedIndex ?? 0
    }
}
