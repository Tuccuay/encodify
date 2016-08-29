//
//  EToast.h
//  encodify
//
//  Created by 洪朔 on 16/8/29.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EToast : NSObject

+ (void)showStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string;

@end
