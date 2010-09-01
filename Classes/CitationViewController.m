    //
//  CitationViewController.m
//  Reader
//
//  Created by Tom Brow on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CitationViewController.h"


@implementation CitationViewController

@synthesize textView, citation;

- (id)init {
    if (self = [super initWithNibName:@"CitationViewController" bundle:nil]) {
    }
    return self;
}

- (void)dealloc {
	[citation release];
	[textView release];
    [super dealloc];
}

- (void) configureViews {
	textView.text = citation.citationString;
}

#pragma mark accessors

- (void) setCitation:(Citation *)value {
	[citation autorelease];
	citation = [value retain];
	
	[self configureViews];
}

#pragma mark UIViewController methods

- (void) viewDidLoad {
	[super viewDidLoad];
	[self configureViews];
}

- (void)viewDidUnload {
	self.textView = nil;
    [super viewDidUnload];
}

- (CGSize) contentSizeForViewInPopover {
	return CGSizeMake(360, 154);
}

@end
