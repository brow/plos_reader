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

@synthesize toolbar, popoverController, paper, leavesView, activityIndicator, pageLabel, 
citationButton, citationLabel, scrollView, innerShadowView;

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
		activityIndicator.hidden = YES;
		leavesView.hidden = YES;
		pageLabel.alpha = 0;
		citationLabel.alpha = 0;
		citationButton.alpha = 0;
	}
	else if (paper.downloaded) {
		leavesView.hidden = NO;
		activityIndicator.hidden = YES;
		
		[UIView beginAnimations:@"" context:nil];
		[UIView setAnimationDuration:0.4];
		citationButton.alpha = 1;
		citationLabel.alpha = 1;
		pageLabel.alpha = 1;
		[UIView commitAnimations];
		
		if (!pdf)
			pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:paper.localPDFPath]);
		
		[leavesView reloadData];
		[self displayPageNumber:1];
		citationLabel.text = paper.runningHead;
	} else {
		leavesView.hidden = YES;
		activityIndicator.hidden = NO;
		pageLabel.alpha = 0;
		citationLabel.alpha = 0;
		citationButton.alpha = 0;
		[paper load];
	}
}

- (void) configureForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		scrollView.scrollEnabled = YES;
		innerShadowView.frame = CGRectMake(0, toolbar.frame.size.height, 
										   self.view.bounds.size.width + 100, 
										   self.view.bounds.size.height - toolbar.frame.size.height + 100);
	} else {
		scrollView.scrollEnabled = NO;
		innerShadowView.frame = CGRectMake(-100, toolbar.frame.size.height, 
										   self.view.bounds.size.width + 200, 
										   self.view.bounds.size.height - toolbar.frame.size.height + 100);
	}
	
}

- (void) showMasterPopover {
	if (toolbar.items.count == 0)
		return;
	UIBarButtonItem *masterButton = [toolbar.items objectAtIndex:0];
	[masterButton.target performSelector:masterButton.action];
}

#pragma mark actions

- (IBAction) showCitationActions:(id)sender {
	citationActionSheet = [[[UIActionSheet alloc] initWithTitle:paper.citation 
															 delegate:self 
													cancelButtonTitle:nil 
											   destructiveButtonTitle:nil 
													 otherButtonTitles:@"Copy Citation",@"Email PDF",nil] autorelease];
	citationActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[citationActionSheet showFromRect:citationButton.frame 
					   inView:citationButton.superview 
					 animated:YES];
}

- (IBAction) emailPDF:(id)sender {
	MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailController setSubject:paper.title];
	[mailController setMessageBody:paper.citation isHTML:NO];
	[mailController addAttachmentData:[NSData dataWithContentsOfFile:paper.localPDFPath] 
							 mimeType:@"application/pdf" 
							 fileName:[[paper.metadata objectForKey:@"doi"] lastPathComponent]
	 ];
	mailController.mailComposeDelegate = self;
	[super presentModalViewController:mailController animated:YES];
}

- (IBAction) copyCitation:(id)sender {
	[[UIPasteboard generalPasteboard] setString:paper.citation];
}

#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller 
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[super dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	citationActionSheet = nil;
}

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[self copyCitation:self];
			break;

		case 1:
			[self emailPDF:self];
			break;
		default:
			break;
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
		CGRect croppedRect = CGRectInset(pageRect, 46, 44);
		croppedRect.origin.y -= 2;
		CGAffineTransform transform = aspectFit(croppedRect,
												CGContextGetClipBoundingBox(ctx));
		CGRect clipRect = CGRectApplyAffineTransform(croppedRect, transform);
		
		CGContextSaveGState(ctx);
		CGContextClipToRect(ctx, clipRect);
		CGContextConcatCTM(ctx, transform);
		CGContextDrawPDFPage(ctx, page);
		CGContextRestoreGState(ctx);
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
    [toolbar setItems:items animated:NO];
    [items release];
    self.popoverController = nil;
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[citationActionSheet dismissWithClickedButtonIndex:2 animated:YES];
	scrollView.contentSize = leavesView.frame.size;
	[self configureForInterfaceOrientation:interfaceOrientation];
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
	
	scrollView.canCancelContentTouches = NO;
	scrollView.delaysContentTouches = NO;
	scrollView.leavesView = leavesView;
	
	[self configureForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidUnload {
    self.popoverController = nil;
}

@end
