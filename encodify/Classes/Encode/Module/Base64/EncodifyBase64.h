//
//  EncodifyBase64.h
//  ArgotAssistant
//
//  Created by 朔 洪 on 16/1/9.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodifyBase64 : NSObject

+ (NSString *)encodeByBase64WithString:(NSString *)string;
+ (NSString *)decodeByBase64WithString:(NSString *)string;

@end
