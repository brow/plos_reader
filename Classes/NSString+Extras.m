//
//  NSString+Extras.m
//  Reader
//
//  Created by Tom Brow on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+Extras.h"


@implementation NSString(Extras)

- (NSString *) initials {
	NSMutableString *ret = [NSMutableString stringWithString:self];
	
	NSMutableCharacterSet *initialCharacters = [[[NSMutableCharacterSet alloc] init] autorelease];
	[initialCharacters formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
	[initialCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
	NSCharacterSet *nonInitialCharacters = [initialCharacters invertedSet];
	
	while (true) {
		NSRange charRange = [ret rangeOfCharacterFromSet:nonInitialCharacters];
		if (charRange.location == NSNotFound)
			break;
		else
			[ret replaceCharactersInRange:charRange withString:@""];
	}
	
	return ret;
}

@end
