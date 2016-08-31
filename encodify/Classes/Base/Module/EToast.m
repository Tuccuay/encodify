//
//  EToast.m
//  encodify
//
//  Created by 洪朔 on 16/8/29.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "EToast.h"

#import <UIKit/UIKit.h>

#import "CWStatusBarNotification.h"

@implementation EToast

+ (void)showStatus:(NSString *)string {
    CWStatusBarNotification *notification = [[CWStatusBarNotification alloc] init];
    notification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.82 green:0.01 blue:0.11 alpha:1.0];
    notification.notificationLabelTextColor = [UIColor whiteColor];
    [notification displayNotificationWithMessage:string forDuration:0.6];
}

+ (void)showErrorWithStatus:(NSString *)string {
    CWStatusBarNotification *notification = [[CWStatusBarNotification alloc] init];
    [notification displayNotificationWithMessage:string forDuration:0.6];
}

@end
