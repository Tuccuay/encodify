//
//  EncodifyUnicode.h
//  ArgotAssistant
//
//  Created by 朔 洪 on 16/1/9.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodifyUnicode : NSObject

+ (NSString *)encodeToUnicodeStringWithString:(NSString *)string;
+ (NSString *)decodeByUnicodeStringWIthString:(NSString *)string;

@end
