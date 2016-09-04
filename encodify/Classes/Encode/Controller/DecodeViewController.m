//
//  DecodeViewController.m
//  encodify
//
//  Created by 洪朔 on 16/8/31.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "DecodeViewController.h"

#import "EncodifyBase64.h"
#import "EncodifyUnicode.h"
#import "EncodifyMorse.h"
#import "EncodifyURI.h"

@interface DecodeViewController ()

@end

@implementation DecodeViewController

- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController {
    return @"Decode";
}

- (NSString *)encodeWithBase64:(NSString *)inputString {
    return [EncodifyBase64 decodeByBase64WithString:inputString];
}

- (NSString *)encodeWithUnicode:(NSString *)inputString {
    return [EncodifyUnicode decodeByUnicodeStringWIthString:inputString];
}

- (NSString *)encodeWithMorse:(NSString *)inputString {
    return [EncodifyMorse decodeByMorseWithString:inputString];
}

- (NSString *)encodeWithURI:(NSString *)inputString {
    return [EncodifyURI decodeByURIWithString:inputString];
}

- (NSString *)encodeButtonTitle {
    return @"Decode";
}

@end
