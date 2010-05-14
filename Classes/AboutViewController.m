    //
//  AboutViewController.m
//  Reader
//
//  Created by Tom Brow on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

- (id)init {
    if ((self = [super initWithNibName:@"AboutViewController" bundle:nil])) {
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark actions

- (IBAction) dismiss:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


@end
