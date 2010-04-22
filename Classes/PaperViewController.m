//
//  DetailViewController.m
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PaperViewController.h"
#import "FeedViewController.h"
#import "Utilities.h"

@interface PaperViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation PaperViewController

@synthesize toolbar, popoverController, paper, leavesView, activityIndicator;

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
    [paper release];
    [super dealloc];
}

- (void)setPaper:(id)newDetailItem {
    if (paper != newDetailItem) {
        [paper release];
        paper = [newDetailItem retain];
		
		if (pdf) {
			CGPDFDocumentRelease(pdf);
			pdf = nil;
		}
		
		[self configureView];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
	if (paper.downloaded) {
		leavesView.hidden = NO;
		activityIndicator.hidden = YES;
		if (!pdf)
			pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:paper.localPath]);
		
		[leavesView reloadData];
	} else {
		leavesView.hidden = YES;
		activityIndicator.hidden = NO;
		[paper load];
		[paper addObserver:self 
				forKeyPath:@"downloaded" 
				   options:NSKeyValueObservingOptionNew 
				   context:nil];
	}
}

#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self configureView];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	return pdf ? CGPDFDocumentGetNumberOfPages(pdf) : 0;
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	if (pdf) {
		CGPDFPageRef page = CGPDFDocumentGetPage(pdf, index + 1);
		CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);		
		CGRect croppedRect = CGRectInset(pageRect, 46, 42);
		croppedRect.origin.y -= 3;
		CGAffineTransform transform = aspectFit(croppedRect,
												CGContextGetClipBoundingBox(ctx));
		CGContextConcatCTM(ctx, transform);
		CGContextDrawPDFPage(ctx, page);
	}
}

#pragma mark UISplitViewControllerDelegate methods

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    barButtonItem.title = @"Papers";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	leavesView.dataSource = self;
	leavesView.delegate = self;
	[self configureView];
}

- (void)viewDidUnload {
    self.popoverController = nil;
}

@end
