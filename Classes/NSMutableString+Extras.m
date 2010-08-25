//
//  NSMutableString+Extras.m
//  Reader
//
//  Created by Tom Brow on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSMutableString+Extras.h"


@implementation NSMutableString(Extras)

- (void) replaceOccurrenceOfPattern:(NSString *)target withString:(NSString *)replacement {
	NSRange targetRange = [super rangeOfString:target options:NSRegularExpressionSearch];
	if (targetRange.location != NSNotFound)
		[self replaceCharactersInRange:targetRange withString:replacement];
}

@end
