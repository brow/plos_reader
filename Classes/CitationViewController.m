    //
//  CitationViewController.m
//  Reader
//
//  Created by Tom Brow on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CitationViewController.h"


@implementation CitationViewController

@synthesize textView, citation, openButton, emailButton, copyButton, delegate;

- (id)init {
    if (self = [super initWithNibName:@"CitationViewController" bundle:nil]) {
    }
    return self;
}

- (void)dealloc {
	[citation release];
	[textView release];
	[openButton release];
	[emailButton release];
	[copyButton release];
    [super dealloc];
}

- (void) configureViews {
	textView.text = citation.citationString;
	
	CGSize textSize = [textView.text sizeWithFont:textView.font
								constrainedToSize:CGSizeMake(textView.frame.size.width, HUGE_VALF)
									lineBreakMode:textView.lineBreakMode];
	textView.frame = CGRectMake(10,//textView.frame.origin.x,
								10,//textView.frame.origin.y,
								textView.frame.size.width,
								textSize.height);
}

#pragma mark accessors

- (void) setCitation:(Citation *)value {
	[citation autorelease];
	citation = [value retain];
	
	[self configureViews];
}

#pragma mark action

- (IBAction) openCitation:(id)sender {
	[delegate citationViewController:self didOpenCitation:citation];
}

- (IBAction) emailCitation:(id)sender {
	[delegate citationViewController:self didEmailCitation:citation];
}

- (IBAction) copyCitation:(id)sender {
	[delegate citationViewController:self didCopyCitation:citation];
}

#pragma mark UIViewController methods

- (void) viewDidLoad {
	[super viewDidLoad];
	
	UIImage *buttonImage = [[UIImage imageNamed:@"SmallBlackButton.png"] stretchableImageWithLeftCapWidth:30 
																							 topCapHeight:12];
	for (UIButton *button in [NSArray arrayWithObjects:openButton,emailButton,copyButton,nil])
		[button setBackgroundImage:buttonImage 
						  forState:UIControlStateNormal];
	
	[self configureViews];
}

- (void)viewDidUnload {
	self.textView = nil;
	self.openButton = nil;
	self.emailButton = nil;
	self.copyButton = nil;
    [super viewDidUnload];
}

- (CGSize) contentSizeForViewInPopover {
	return CGSizeMake(textView.frame.size.width + 20,
					  textView.frame.size.height + 63);
	
	return CGSizeMake(360, 150);
	
}

@end
