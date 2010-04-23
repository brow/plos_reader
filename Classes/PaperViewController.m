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

@synthesize toolbar, popoverController, paper, leavesView, activityIndicator, pageLabel, citationButton, citationLabel;

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
    [paper release];
    [super dealloc];
}

- (void)setPaper:(id)newDetailItem {
    if (paper != newDetailItem) {	
		[paper removeObserver:self forKeyPath:@"downloaded"];
		
        [paper release];
        paper = [newDetailItem retain];
				
		[paper addObserver:self 
				forKeyPath:@"downloaded" 
				   options:NSKeyValueObservingOptionNew 
				   context:nil];
		
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

- (void) displayPageNumber:(NSUInteger)pageNumber {
	pageLabel.text = [NSString stringWithFormat:
						 @"%u / %u", 
						 pageNumber, 
						 CGPDFDocumentGetNumberOfPages(pdf)];
}

- (void)configureView {
	if (!paper) {
		pageLabel.hidden = YES;
		activityIndicator.hidden = YES;
		leavesView.hidden = YES;
		citationLabel.hidden = YES;
		citationButton.enabled = NO;
	}
	else if (paper.downloaded) {
		pageLabel.hidden = NO;
		leavesView.hidden = NO;
		citationLabel.hidden = NO;
		citationButton.enabled = YES;
		activityIndicator.hidden = YES;
		
		if (!pdf)
			pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:paper.localPDFPath]);
		
		[leavesView reloadData];
		[self displayPageNumber:1];
		citationLabel.text = paper.volumeIssueId;
	} else {
		pageLabel.hidden = YES;
		leavesView.hidden = YES;
		citationLabel.hidden = YES;
		citationButton.enabled = NO;
		activityIndicator.hidden = NO;
		[paper load];
	}
}

#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self configureView];
}

#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)leavesView didTurnToPageAtIndex:(NSUInteger)pageIndex {
	[self displayPageNumber:pageIndex + 1];
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
	
	[citationButton setBackgroundImage:[[UIImage imageNamed:@"CitationButton.png"] stretchableImageWithLeftCapWidth:10 
																									   topCapHeight:10]
							  forState:UIControlStateNormal];
	[citationButton setBackgroundImage:[[UIImage imageNamed:@"CitationButtonHighlighted.png"] stretchableImageWithLeftCapWidth:10 
																												  topCapHeight:10]
							  forState:UIControlStateHighlighted];
}

- (void)viewDidUnload {
    self.popoverController = nil;
}

@end
