//
//  MagnifierViewController.m
//  Reader
//
//  Created by Tom Brow on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MagnifierViewController.h"


@implementation MagnifierViewController

@synthesize delegate;

- (id)initWithParentViewController:(PaperViewController *)aParent {
    if (self = [super initWithNibName:@"MagnifierViewController" bundle:nil]) {
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		parent = [aParent retain];
		paper = [parent.paper retain];
    }
    return self;
}

- (void) dealloc
{
	[parent release];
	[super dealloc];
}


#pragma mark actions

- (IBAction) toggleMagnification:(id)sender {
	[delegate magnifierViewControllerDidFinish:self];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)aleavesView {
	return [parent numberOfPagesInLeavesView:aleavesView];
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	[parent renderPageAtIndex:index inContext:ctx];
}

#pragma mark PaperViewController methods

- (void) configureForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	self.leavesView.preferredTargetWidth = 90;
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
