//
//  EncodifyBase64.m
//  ArgotAssistant
//
//  Created by 朔 洪 on 16/1/9.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "EncodifyBase64.h"

@implementation EncodifyBase64

+ (NSString *)encodeByBase64WithString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [data base64EncodedStringWithOptions:0];
    return base64Encoded;
}

+ (NSString *)decodeByBase64WithString:(NSString *)string {
    NSData *dataFromBase64String = [[NSData alloc] initWithBase64EncodedString:string options:0];
    NSString *base64Decoded = [[NSString alloc] initWithData:dataFromBase64String encoding:NSUTF8StringEncoding];
    return base64Decoded;
}

@end
