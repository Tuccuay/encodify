//
//  EncodeViewController.m
//  encodify
//
//  Created by 洪朔 on 16/8/31.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "EncodeViewController.h"

#import "EncodifyBase64.h"
#import "EncodifyUnicode.h"
#import "EncodifyMorse.h"
#import "EncodifyURI.h"

@interface EncodeViewController ()

@end

@implementation EncodeViewController

- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController {
    return @"Encode";
}

- (NSString *)encodeWithBase64:(NSString *)inputString {
    return [EncodifyBase64 encodeByBase64WithString:inputString];
}

- (NSString *)encodeWithUnicode:(NSString *)inputString {
    return [EncodifyUnicode encodeToUnicodeStringWithString:inputString];
}

- (NSString *)encodeWithMorse:(NSString *)inputString {
    return [EncodifyMorse encodeByMorseWithString:inputString];
}

- (void)encodeWithMorse:(NSString *)inputString textView:(UITextView *)textView {
    [EncodifyXmorseBridge encode:inputString complection:^(NSString *string) {
        textView.text = string;
    }];
}

- (NSString *)encodeWithURI:(NSString *)inputString {
    return [EncodifyURI encodeByURIWithString:inputString];
}

- (NSString *)encodeButtonTitle {
    return @"Encode";
}

@end
