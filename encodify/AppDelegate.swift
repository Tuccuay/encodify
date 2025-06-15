//
//  AppDelegate.swift
//  encodify
//
//  Created by 洪朔 on 2024/12/20.
//  Copyright © 2024年 Tuccuay. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 初始化系统主题管理器
        _ = ThemeManager.shared
        
        // 配置应用外观
        Task { @MainActor in
            AppearanceManager.shared.configureAppearance()
            AppearanceManager.shared.configureDynamicTypeSupport()
            AppearanceManager.shared.configureAccessibilitySupport()
        }
        
        return true
    }
    
    private func setupWindowForLegacyiOS() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // 使用 AppCoordinator 管理界面 (启动时已经在主线程)
        if let window = window {
            appCoordinator = AppCoordinator(window: window)
            appCoordinator?.start()
        }
    }

    // MARK: - UISceneSession Lifecycle (iOS 13+)
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }

    // MARK: - Application Lifecycle (iOS 12 and below)
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused while the application was inactive.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate.
    }

    // MARK: - Private Methods
}
