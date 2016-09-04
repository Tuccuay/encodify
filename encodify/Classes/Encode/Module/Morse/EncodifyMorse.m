//
//  EncodifyMores.m
//  ArgotAssistant
//
//  Created by 朔 洪 on 16/1/9.
//  Copyright © 2016年 Tuccuay. All rights reserved.
//

#import "EncodifyMorse.h"

#import "MorseParser.h"
#import "MCGMorseCodeConverter.h"

@implementation EncodifyMorse

+ (NSString *)encodeByMorseWithString:(NSString *)string {
    NSMutableArray * morseCodeStringArray = [@[] mutableCopy];
    MCGMorseCodeConverter *converter = [[MCGMorseCodeConverter alloc] init];
    NSArray *morseCodeArray = [converter convertStringToMorseCodes:string];
    [morseCodeArray enumerateObjectsUsingBlock:^(NSNumber * morseCodeNumber, NSUInteger idx, BOOL *stop) {
        
        switch ([morseCodeNumber integerValue]) {
            case MCGMorseCodeDit:
                [morseCodeStringArray addObject:kMorseCodeDitString];
                break;
            case MCGMorseCodeDah:
                [morseCodeStringArray addObject:kMorseCodeDahString];
                break;
            case MCGMorseCodeSingleSpace:
                [morseCodeStringArray addObject:kMorseCodeDahSpaceString];
                break;
            case MCGMorseCodeThreeSpaces:
                [morseCodeStringArray addObject:kMorseCodeDahThreeSpacesString];
                break;
            default:
                break;
        }
    }];
    NSString *morseCodeString = [morseCodeStringArray componentsJoinedByString:@""];
//    NSLog(@"%@", morseCodeString);
    return morseCodeString;
}

+ (NSString *)decodeByMorseWithString:(NSString *)string {
//    NSLog(@"str %@", string);
    NSString *reTreString = [string stringByReplacingOccurrencesOfString:@"   "withString:@"/=/"];
//    NSLog(@"reTre %@", reTreString);
    NSString *reSpeString = [reTreString stringByReplacingOccurrencesOfString:@" " withString:@"/"];
//    NSLog(@"resSpe %@", reSpeString);
    
    return [MorseParser parseString:reSpeString];
}

@end
