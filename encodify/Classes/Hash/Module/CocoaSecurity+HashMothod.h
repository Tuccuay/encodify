//
//  CocoaSecurity+HashMothod.h
//  encodify
//
//  Created by 洪朔 on 16/8/28.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import <CocoaSecurity/CocoaSecurity.h>

@interface CocoaSecurity (HashMothod)

+ (CocoaSecurityResult *)md2:(NSString *)hashString;
+ (CocoaSecurityResult *)md4:(NSString *)hashString;

@end
