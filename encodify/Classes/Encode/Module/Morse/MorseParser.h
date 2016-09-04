//
//  MorseParser.h
//  Morse
//
//  Created by Adam Benzan on 09-07-25.
//  Copyright 2009 Saltmine Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MorseParser : NSObject {

}
+(NSString*)parseLetterIMF:(NSString*)letterToParse;
+(NSString*)parseString:(NSString*)stringToParse;
@end
