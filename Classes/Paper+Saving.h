//
//  Paper+Saving.h
//  Reader
//
//  Created by Tom Brow on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Paper.h"


@interface Paper(Saving)

+ (NSArray *) savedPapers;
- (void) save;
- (BOOL) saved;
- (void) restore;

@end
