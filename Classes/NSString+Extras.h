//
//  NSString+Extras.h
//  Reader
//
//  Created by Tom Brow on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(Extras) 

- (NSString *) initials;
- (BOOL) containsString:(NSString *)string;
- (BOOL) containsStrings:(NSArray *)strings;

@end
