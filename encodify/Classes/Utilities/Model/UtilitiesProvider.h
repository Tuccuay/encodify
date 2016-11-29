//
//  UtilitiesProvider.h
//  encodify
//
//  Created by 洪朔 on 2016/11/30.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilitiesProvider : NSObject

@property (copy, nonatomic) NSString *className;
@property (copy, nonatomic) NSString *title;

+ (instancetype)title:(NSString *)title className:(NSString *)className;

@end
