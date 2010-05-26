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

- (id)initWithPaper:(Paper *)aPaper {
    if ((self = [super initWithNibName:@"MagnifierViewController" bundle:nil])) {
		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		self.paper = aPaper;
    }
    return self;
}

#pragma mark actions

- (IBAction) toggleMagnification:(id)sender {
	[delegate setPage:self.page];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
