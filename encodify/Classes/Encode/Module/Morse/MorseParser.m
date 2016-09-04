//
//  MorseParser.m
//  Morse
//
//  Created by Adam Benzan on 09-07-25.
//  Copyright 2009 Saltmine Software. All rights reserved.
//

#import "MorseParser.h"


@implementation MorseParser

+(NSString*)parseLetterIMF:(NSString *)letterToParse {
	if ([letterToParse isEqualToString:@".-"]) { return @"A"; }
	else if ([letterToParse isEqualToString:@"-..."]) { return @"B"; }
	else if ([letterToParse isEqualToString:@"-.-."]) { return @"C"; }
	else if ([letterToParse isEqualToString:@"-.."]) { return @"D"; }
	else if ([letterToParse isEqualToString:@"."]) { return @"E"; }
	else if ([letterToParse isEqualToString:@"..-."]) { return @"F"; }
	else if ([letterToParse isEqualToString:@"--."]) { return @"G"; }
	else if ([letterToParse isEqualToString:@"...."]) { return @"H"; }
	else if ([letterToParse isEqualToString:@".."]) { return @"I"; }
	else if ([letterToParse isEqualToString:@".---"]) { return @"J"; }
	else if ([letterToParse isEqualToString:@"-.-"]) { return @"K"; }
	else if ([letterToParse isEqualToString:@".-.."]) { return @"L"; }
	else if ([letterToParse isEqualToString:@"--"]) { return @"M"; }
	else if ([letterToParse isEqualToString:@"-."]) { return @"N"; }
	else if ([letterToParse isEqualToString:@"---"]) { return @"O"; }
	else if ([letterToParse isEqualToString:@".--."]) { return @"P"; }
	else if ([letterToParse isEqualToString:@"--.-"]) { return @"Q"; }
	else if ([letterToParse isEqualToString:@".-."]) { return @"R"; }
	else if ([letterToParse isEqualToString:@"..."]) { return @"S"; }
	else if ([letterToParse isEqualToString:@"-"]) { return @"T"; }
	else if ([letterToParse isEqualToString:@"..-"]) { return @"U"; }
	else if ([letterToParse isEqualToString:@"...-"]) { return @"V"; }
	else if ([letterToParse isEqualToString:@".--"]) { return @"W"; }
	else if ([letterToParse isEqualToString:@"-..-"]) { return @"X"; }
	else if ([letterToParse isEqualToString:@"-.--"]) { return @"Y"; }
	else if ([letterToParse isEqualToString:@"--.."]) { return @"Z"; }
	else if ([letterToParse isEqualToString:@".----"]) { return @"1"; }
	else if ([letterToParse isEqualToString:@"..---"]) { return @"2"; }
	else if ([letterToParse isEqualToString:@"...--"]) { return @"3"; }
	else if ([letterToParse isEqualToString:@"....-"]) { return @"4"; }
	else if ([letterToParse isEqualToString:@"....."]) { return @"5"; }
	else if ([letterToParse isEqualToString:@"-...."]) { return @"6"; }
	else if ([letterToParse isEqualToString:@"--..."]) { return @"7"; }
	else if ([letterToParse isEqualToString:@"---.."]) { return @"8"; }
	else if ([letterToParse isEqualToString:@"----."]) { return @"9"; }
	else if ([letterToParse isEqualToString:@"-----"]) { return @"0"; }
	else if ([letterToParse isEqualToString:@".-.-.-"]) { return @"."; }
	else if ([letterToParse isEqualToString:@"--..--"]) { return @","; }
	else if ([letterToParse isEqualToString:@"="]) { return @" "; }
	return @"?";
}

+(NSString*)parseString:(NSString *)stringToParse {
	NSArray *letters = [stringToParse componentsSeparatedByString:@"/"];
	NSString *resultString = @"";
	for (NSString* letter in letters) {
		resultString = [resultString stringByAppendingString:[MorseParser parseLetterIMF:letter]];
	}
	return resultString;
}

@end
