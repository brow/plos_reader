//
//  MagnifierViewController.h
//  Reader
//
//  Created by Tom Brow on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PaperViewController.h"
#import "LeavesCache.h"

@interface  MagnifierViewController : PaperViewController <LeavesViewCache> {
	id delegate;
	id<LeavesViewCache> pageCache;
	BOOL renderingEnabled;
}

@property (assign) id delegate;

- (id)initWithPaper:(Paper *)aPaper cache:(id<LeavesViewCache>)aCache;

@end
