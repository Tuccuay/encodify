//
//  UtilitiesProvider.m
//  encodify
//
//  Created by 洪朔 on 2016/11/30.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "UtilitiesProvider.h"

@implementation UtilitiesProvider

+ (instancetype)title:(NSString *)title className:(NSString *)className {
    
    UtilitiesProvider *provider = [[self alloc] init];
    provider.title = title;
    provider.className = className;
    
    return provider;
}

@end
