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

- (id)initWithPaper:(Paper *)aPaper cache:(id<LeavesViewCache>)aCache {
    if (self = [super initWithNibName:@"MagnifierViewController" bundle:nil]) {
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		paper = [aPaper retain];
		pageCache = [aCache retain];
		renderingEnabled = NO;
    }
    return self;
}

- (void) dealloc
{
	[pageCache release];
	[super dealloc];
}


#pragma mark actions

- (IBAction) toggleMagnification:(id)sender {
	[delegate setPage:self.page];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark LeavesViewCache methods

- (CGSize) pageSize {
	return pageCache.pageSize;
}

- (void)setPageSize:(CGSize)aPageSize {
	pageCache.pageSize = aPageSize;
}

- (CGImageRef) imageForPageAtIndex:(NSUInteger)index fromDataSource:(id<LeavesViewDataSource>)dataSource {
	if (renderingEnabled)
		return [pageCache imageForPageAtIndex:index fromDataSource:dataSource];
	else
		return nil;
}

- (void) flush {
	// since we're borrowing another LeavesView's cache, we shouldn't flush it
}

- (void) precacheImageForPageIndex:(NSUInteger)index fromDataSource:(id<LeavesViewDataSource>)dataSource {
	if (renderingEnabled)
		[pageCache precacheImageForPageIndex:index fromDataSource:dataSource];
}

- (void) minimizeToPageIndex:(NSUInteger)index {
	if (renderingEnabled)
		[pageCache minimizeToPageIndex:index];
}

#pragma mark  LeavesViewDataSource methods

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	if (renderingEnabled)
		[super renderPageAtIndex:index inContext:ctx];
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) viewDidLoad {
	self.leavesView.cache = self;
	[super viewDidLoad];
	renderingEnabled = YES;
}

@end
