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

@interface  MagnifierViewController : PaperViewController {
	id<MagnifierViewControllerDelegate> delegate;
	PaperViewController *parent;
}

@property (assign) id<MagnifierViewControllerDelegate> delegate;

- (id)initWithParentViewController:(PaperViewController *)aParent;

@end


@protocol MagnifierViewControllerDelegate

- (void) magnifierViewControllerDidFinish:(MagnifierViewController *)vc;

@end

