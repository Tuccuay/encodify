//
//  EncodifyURI.m
//  encoder
//
//  Created by 朔 洪 on 16/1/12.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "EncodifyURI.h"

@implementation EncodifyURI

+ (NSString *)encodeByURIWithString:(NSString *)string {
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)decodeByURIWithString:(NSString *)string {
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
