//
//  PageScrollView.m
//  Reader
//
//  Created by Tom Brow on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PageScrollView.h"


@implementation PageScrollView

@synthesize leavesView;

- (void) dealloc {
	[leavesView release];
	[super dealloc];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
	CGPoint touchPoint = [[touches anyObject] locationInView:leavesView];
	if (touchPoint.x < leavesView.targetWidth || 
		touchPoint.x > leavesView.bounds.size.width - leavesView.targetWidth)
		return YES;
	else
		return NO;
}

@end
