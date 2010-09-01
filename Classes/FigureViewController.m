    //
//  FigureViewController.m
//  Reader
//
//  Created by Tom Brow on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FigureViewController.h"


@implementation FigureViewController

@synthesize figureImage, imageView, scrollView;

- (id)init {
    if (self = [super init]) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
	[imageView release];
	[scrollView release];
	[figureImage release];
	[super dealloc];
}

- (void) configureViews {
	self.imageView.image = figureImage;
	self.imageView.frame = CGRectMake(0, 0, figureImage.size.width, figureImage.size.height);
	self.scrollView.contentSize = figureImage.size;
	
	
	self.scrollView.minimumZoomScale = MIN([self contentSizeForViewInPopover].width / figureImage.size.width,
										   [self contentSizeForViewInPopover].height / figureImage.size.height);
	self.scrollView.maximumZoomScale = 1.0;
}

#pragma mark accessors

- (void)setFigureImage:(UIImage *)value {
	[figureImage autorelease];
	figureImage = [value retain];
	
	
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
	return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
	
}

#pragma mark UIViewController methods

- (CGSize) contentSizeForViewInPopover {
	return CGSizeMake(MIN(700, figureImage.size.width), 
					  MIN(700, figureImage.size.height));
}

- (void)loadView {
	self.imageView = [[[UIImageView alloc] init] autorelease];
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView.backgroundColor = [UIColor redColor];
	
	self.scrollView = [[[UIScrollView alloc] init] autorelease];
	self.scrollView.delegate = self;
	[self.scrollView addSubview:self.imageView];
	
	self.view = scrollView;
	[self configureViews];
}

- (void)viewDidUnload {
	self.imageView = nil;
	self.scrollView = nil;
    [super viewDidUnload];
}

@end
