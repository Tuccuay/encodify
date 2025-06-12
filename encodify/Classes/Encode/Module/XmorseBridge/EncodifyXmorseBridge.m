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
   completion:(xmorseBridge)completion {

    [self morseMethod:@"encode" string:string completion:completion];
}

+ (void)decode:(NSString *)string
   completion:(xmorseBridge)completion {

    [self morseMethod:@"decode" string:string completion:completion];
}

+ (void)morseMethod:(NSString *)method
             string:(NSString *)string
        completion:(xmorseBridge)completion {
    
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
        completion(text);
    };
    
    JSValue *morse = context[method];
    [morse callWithArguments:@[string]];
    
}

@end
