//
//  NSObject.m
//  JSCoreTest
//
//  Created by 洪朔 on 2017/1/17.
//  Copyright © 2017年 Tuccuay. All rights reserved.
//

#import "EncodifyXmorseBridge.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation EncodifyXmorseBridge

+ (void)encode:(NSString *)string
   complection:(xmorseBridge)complection {
    
    [self morseMethod:@"encode" string:string complection:complection];
}

+ (void)decode:(NSString *)string
   complection:(xmorseBridge)complection {
    
    [self morseMethod:@"decode" string:string complection:complection];
}

+ (void)morseMethod:(NSString *)method
             string:(NSString *)string
        complection:(xmorseBridge)complection {
    
    NSString *xmorseMinPath = [[NSBundle mainBundle]
                               pathForResource:@"xmorse.min" ofType:@"js"];
    NSString *xmorseMinString = [NSString stringWithContentsOfFile:xmorseMinPath
                                                          encoding:NSUTF8StringEncoding error:nil];
    
    NSString *encodifyXmorseBridgeString =
        @"function encode(string) {"
            "callback(xmorse.encode(string));"
        "}"
        "function decode(string) {"
            "callback(xmorse.decode(string));"
        "}";
    
    JSContext *context = [[JSContext alloc] init];
    
    [context evaluateScript:xmorseMinString];
    [context evaluateScript:encodifyXmorseBridgeString];
    
    context[@"callback"] = ^(NSString *text) {
        complection(text);
    };
    
    JSValue *morse = context[method];
    [morse callWithArguments:@[string]];
    
}

@end
