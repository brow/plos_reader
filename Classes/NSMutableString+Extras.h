//
//  NSMutableString+Extras.h
//  Reader
//
//  Created by Tom Brow on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableString(Extras)

- (void) replaceOccurrenceOfPattern:(NSString *)target withString:(NSString *)replacement;

@end
