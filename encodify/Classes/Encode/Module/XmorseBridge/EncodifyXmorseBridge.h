//
//  NSObject.h
//  JSCoreTest
//
//  Created by 洪朔 on 2017/1/17.
//  Copyright © 2017年 Tuccuay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^xmorseBridge)(NSString *string);

@interface EncodifyXmorseBridge : NSObject

+ (void)encode:(NSString *)string complection:(xmorseBridge)complection;
+ (void)decode:(NSString *)string complection:(xmorseBridge)complection;

@end
