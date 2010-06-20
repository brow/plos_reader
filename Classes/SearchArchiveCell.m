//
//  SearchArchiveCell.m
//  Reader
//
//  Created by Tom Brow on 6/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchArchiveCell.h"


@implementation SearchArchiveCell

@synthesize label, activityIndicator, active;

- (void) awakeFromNib {
	self.active = NO;
	label.highlightedTextColor = [UIColor whiteColor];
}

- (void)dealloc {
	[label release];
	[activityIndicator release];
    [super dealloc];
}

#pragma mark accessors

- (void) setActive:(BOOL)value {
	active = value;
	
	if (active) {
		activityIndicator.hidden = NO;
		label.text = @"Searching in Archive...";
		label.textColor = [UIColor grayColor];
	} else {
		activityIndicator.hidden = YES;
		label.text = @"Continue Search in Archive...";
		label.textColor = [UIColor blueColor]; 
	}
}

@end
