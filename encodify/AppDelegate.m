//
//  AppDelegate.m
//  encodify
//
//  Created by 洪朔 on 16/8/28.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "AppDelegate.h"
#import <CommonCrypto/CommonCrypto.h>

#import "EncodePagerViewController.h"
#import "UtilitiesViewController.h"

#import "UIColor+Helper.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self prepareAppearance];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    EncodePagerViewController *encodePagerViewController = [[EncodePagerViewController alloc] init];
    encodePagerViewController.tabBarItem.title = @"Encode";
    encodePagerViewController.tabBarItem.image = [UIImage imageNamed:@"encode"];
    
    UINavigationController *hashNavigationController = [[UIStoryboard storyboardWithName:@"Hash" bundle:nil] instantiateInitialViewController];
    hashNavigationController.tabBarItem.image = [UIImage imageNamed:@"hash"];
    
    UtilitiesViewController *utilitiesViewController = [[UtilitiesViewController alloc] init];
    utilitiesViewController.title = @"Utilities";
    UINavigationController *utilitiesNavigationController = [[UINavigationController alloc] initWithRootViewController:utilitiesViewController];
    utilitiesNavigationController.tabBarItem.title = @"Utilities";
    utilitiesNavigationController.tabBarItem.image = [UIImage imageNamed:@"Utilities"];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    tabBarController.viewControllers = @[encodePagerViewController, hashNavigationController, utilitiesNavigationController];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    [UINavigationBar appearance].tintColor = [UIColor encodifyTintColor];
    [UIControl appearance].tintColor = [UIColor encodifyTintColor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)prepareAppearance {
    [UIControl appearance].tintColor = [UIColor encodifyTintColor];
    [UITabBar appearance].tintColor = [UIColor encodifyTintColor];
}

@end
