//
//  EncodifyUnicode.m
//  ArgotAssistant
//
//  Created by 朔 洪 on 16/1/9.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "EncodifyUnicode.h"

@implementation EncodifyUnicode

+ (NSString *)encodeToUnicodeStringWithString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUnicodeStringEncoding];
    char *unicodeChar = (char *)[data bytes];
    //跳过unicode前面的FF-FE两个字节。
    unicodeChar +=2;
    [self convertToBigEndian:unicodeChar Length:data.length-2];
    NSMutableString *tempUnicodeStr = [NSMutableString stringWithString:[self HttpUrlEncode:unicodeChar Length:data.length-2]];
    
    //计算有多少个Unicode（\uxxxx这种格式是Unicode写法,表示一个字符,其中xxxx表示一个16进制数字）
    NSUInteger lenge = tempUnicodeStr.length/4;
    //存储所有Unicode
    NSMutableArray *arr = [NSMutableArray array];
    //拆分
    for (int i = 0; i < lenge; i++) {
        NSRange rang;
        rang.length = 4;
        rang.location = i*4;
        [arr addObject:[tempUnicodeStr substringWithRange:rang]];
    }
    //在拆分好的Unicode前面插入"\u"字符
    __block NSString *unicodeStr = @"";
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *tempStr = @"";
        NSString *str = obj;
        tempStr = [@"\\u" stringByAppendingString:str];
        unicodeStr = [unicodeStr stringByAppendingString:tempStr];
    }];
    return unicodeStr;
}

+ (void)convertToBigEndian:(char*)src Length:(NSInteger)len
{
    if(len%2 !=0)
    {
        return ;
    }
    char tmp;
    for (int i=0; i<len; i+=2)
    {
        tmp      = src [i];
        src[i]   = src[i+1];
        src[i+1] = tmp;
    }
}

+ (NSString*)HttpUrlEncode:(char*)srcUrl Length:(NSInteger)len
{
    
    if (len == 0)
    {
        return @"";
    }
    NSString* buf = @"";
    // Parse a the chars in the url
    for (int i=0; i<len; i++)
    {
        char oneChar = srcUrl[i];
        buf = [buf stringByAppendingString:[self UrlEncodeFormat:oneChar]];
        if(i!= len-1)
        {
            buf = [buf stringByAppendingString:@""];
        }
    }
    return buf;
    
}

+ (NSString*)UrlEncodeFormat:(u_char) cValue
{
    NSString* buf=@"";
    
    
    uint nDiv = cValue/16;
    uint nMod = cValue%16;
    
    buf = [buf stringByAppendingString:[self DecimalToHexString:nDiv]];
    buf = [buf stringByAppendingString:[self DecimalToHexString:nMod]];
    return buf;
}

+ (NSString*)DecimalToHexString:(u_char)nValue
{
    NSString* tmp = @"";
    switch(nValue)
    {
        case 0:tmp = @"0";break;
        case 1:tmp = @"1";break;
        case 2:tmp = @"2";break;
        case 3:tmp = @"3";break;
        case 4:tmp = @"4";break;
        case 5:tmp = @"5";break;
        case 6:tmp = @"6";break;
        case 7:tmp = @"7";break;
        case 8:tmp = @"8";break;
        case 9:tmp = @"9";break;
        case 10:tmp = @"a";break;
        case 11:tmp = @"b";break;
        case 12:tmp = @"c";break;
        case 13:tmp = @"d";break;
        case 14:tmp = @"e";break;
        case 15:tmp = @"f";break;
        default:tmp = @"x";
            break;
    }
    return tmp;
}

+ (NSString *)decodeByUnicodeStringWIthString:(NSString *)string {
    NSString *tempStr1 = [string stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *returnStr = [NSPropertyListSerialization propertyListFromData:tempData
//                                                           mutabilityOption:NSPropertyListImmutable
//                                                                     format:NULL
//                                                           errorDescription:NULL];
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:nil error:nil];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    
}

@end
