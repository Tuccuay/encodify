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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        prepareAppearance()
        
        // 修复：添加括号来调用方法
        setupWindowForLegacyiOS()
        
        return true
    }
    
    private func setupWindowForLegacyiOS() {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let encodePagerViewController = EncodePagerViewController()
        encodePagerViewController.tabBarItem.title = "Encode"
        encodePagerViewController.tabBarItem.image = UIImage(named: "encode")
        
        let hashViewController = HashViewController()
        hashViewController.title = "Hash"
        let hashNavigationController = UINavigationController(rootViewController: hashViewController)
        hashNavigationController.tabBarItem.title = "Hash"
        hashNavigationController.tabBarItem.image = UIImage(named: "hash")
        
        let utilitiesViewController = UtilitiesViewController()
        utilitiesViewController.title = "Utilities"
        let utilitiesNavigationController = UINavigationController(rootViewController: utilitiesViewController)
        utilitiesNavigationController.tabBarItem.title = "Utilities"
        utilitiesNavigationController.tabBarItem.image = UIImage(named: "Utilities")
        
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [encodePagerViewController, hashNavigationController, utilitiesNavigationController]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().tintColor = UIColor.encodifyTintColor
        UIControl.appearance().tintColor = UIColor.encodifyTintColor
    }

    // 移除 Scene 相关方法
    
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
    
    private func prepareAppearance() {
        UIControl.appearance().tintColor = UIColor.encodifyTintColor
        UITabBar.appearance().tintColor = UIColor.encodifyTintColor
    }
}
