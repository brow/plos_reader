//
//  MagnifierViewController.h
//  Reader
//
//  Created by Tom Brow on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PaperViewController.h"
#import "LeavesCache.h"

@protocol MagnifierViewControllerDelegate;

@interface  MagnifierViewController : PaperViewController <LeavesViewCache> {
	id<MagnifierViewControllerDelegate> delegate;
	id<LeavesViewCache> pageCache;
	BOOL renderingEnabled;
}

@property (assign) id<MagnifierViewControllerDelegate> delegate;
@property (readonly) id<LeavesViewCache> pageCache;

- (id)initWithPaper:(Paper *)aPaper cache:(id<LeavesViewCache>)aCache;

@end


@protocol MagnifierViewControllerDelegate

- (void) magnifierViewControllerDidFinish:(MagnifierViewController *)vc;

@end

