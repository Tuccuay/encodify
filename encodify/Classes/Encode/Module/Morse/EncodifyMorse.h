//
//  EncodifyMores.h
//  ArgotAssistant
//
//  Created by 朔 洪 on 16/1/9.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodifyMorse : NSObject

+ (NSString *)encodeByMorseWithString:(NSString *)string;
+ (NSString *)decodeByMorseWithString:(NSString *)string;

@end
