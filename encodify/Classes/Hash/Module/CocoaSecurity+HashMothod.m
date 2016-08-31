//
//  CocoaSecurity+HashMothod.m
//  encodify
//
//  Created by 洪朔 on 16/8/28.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "CocoaSecurity+HashMothod.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation CocoaSecurity (HashMothod)

#pragma mark - MD2
+ (CocoaSecurityResult *)md2:(NSString *)hashString
{
    return [self md2WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}
+ (CocoaSecurityResult *)md2WithData:(NSData *)hashData
{
    unsigned char *digest;
    digest = malloc(CC_MD2_DIGEST_LENGTH);

    CC_MD2([hashData bytes], (CC_LONG)[hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_MD2_DIGEST_LENGTH];
    free(digest);

    return result;
}

#pragma mark - MD4
+ (CocoaSecurityResult *)md4:(NSString *)hashString {
    return [self md4WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (CocoaSecurityResult *)md4WithData:(NSData *)hashData {
    unsigned char *digest;
    digest = malloc(CC_MD4_DIGEST_LENGTH);

    CC_MD4([hashData bytes], (CC_LONG)[hashData length], digest);
    CocoaSecurityResult *result = [[CocoaSecurityResult alloc] initWithBytes:digest length:CC_MD4_DIGEST_LENGTH];
    free(digest);

    return result;
}

@end
