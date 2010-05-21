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
#import "Paper+Saving.h"

@interface PaperViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation PaperViewController

@synthesize toolbar, popoverController, paper, leavesView, downloadingView, pageLabel, 
citationButton, citationLabel, scrollView, innerShadowView, progressIndicator, downloadingTitleLabel;

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
    [paper release];
    [super dealloc];
}

- (void)setPaper:(id)newDetailItem {
    if (paper != newDetailItem) {	
		[paper removeObserver:self forKeyPath:@"downloadStatus"];
		[paper removeObserver:self forKeyPath:@"downloadProgress"];
		[paper cancelLoad];
		
        [paper release];
        paper = [newDetailItem retain];
				
		[paper addObserver:self 
				forKeyPath:@"downloadStatus" 
				   options:NSKeyValueObservingOptionNew 
				   context:nil];
		[paper addObserver:self 
				forKeyPath:@"downloadProgress" 
				   options:NSKeyValueObservingOptionNew 
				   context:nil];
		
		[self configureView];
		if (paper.downloadStatus != StatusDownloaded)
			[paper load];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}

- (void) displayPageNumber:(NSUInteger)pageNumber {
	pageLabel.text = [NSString stringWithFormat:
						 @"%u / %u", 
						 pageNumber, 
						 [self numberOfPagesInLeavesView:leavesView]];
}

- (void)configureMasterButton {
	if (paper)
		masterButton.title = paper.shortJournalTitle;
	else
		masterButton.title = @"Journals";
}

- (void)configureView {
	if (!paper || paper.downloadStatus == StatusFailed) {
		downloadingView.hidden = YES;
		leavesView.hidden = YES;
		pageLabel.alpha = 0;
		citationLabel.alpha = 0;
		citationButton.alpha = 0;
	}
	else if (paper.downloadStatus == StatusDownloaded) {
		leavesView.hidden = NO;
		downloadingView.hidden = YES;
		
		[UIView beginAnimations:@"" context:nil];
		[UIView setAnimationDuration:0.4];
		citationButton.alpha = 1;
		citationLabel.alpha = 1;
		pageLabel.alpha = 1;
		[UIView commitAnimations];
		[leavesView reloadData];
		[self displayPageNumber:leavesView.currentPageIndex+1];
		citationLabel.text = paper.runningHead;
	} else {
		leavesView.hidden = YES;
		downloadingView.hidden = NO;
		pageLabel.alpha = 0;
		citationLabel.alpha = 0;
		citationButton.alpha = 0;
		downloadingTitleLabel.text = paper.title;
		
		CGSize titleLabelSize = [downloadingTitleLabel.text sizeWithFont:downloadingTitleLabel.font
													   constrainedToSize:CGSizeMake(downloadingTitleLabel.frame.size.width,
																					 HUGE_VALF)
														   lineBreakMode:downloadingTitleLabel.lineBreakMode];
		downloadingTitleLabel.frame = CGRectMake(downloadingTitleLabel.frame.origin.x, 
												 downloadingTitleLabel.frame.origin.y, 
												 downloadingTitleLabel.frame.size.width, 
												 titleLabelSize.height);
	}
	
	[self configureMasterButton];
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
	[masterButton.target performSelector:masterButton.action];
}

#pragma mark properties

- (NSUInteger)page {
    return leavesView.currentPageIndex;
}

- (void)setPage:(NSUInteger)value {
    leavesView.currentPageIndex = value;
	[self displayPageNumber:value+1];
}

#pragma mark actions

- (IBAction) showCitationActions:(id)sender {
	citationActionSheet = [[[UIActionSheet alloc] initWithTitle:paper.citation 
															 delegate:self 
													cancelButtonTitle:nil 
											   destructiveButtonTitle:nil 
													 otherButtonTitles:@"Copy Citation",@"Email Article",nil] autorelease];
	if (!paper.saved)
		  [citationActionSheet addButtonWithTitle:@"Save Article"];
	citationActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[citationActionSheet showFromRect:citationButton.frame 
					   inView:citationButton.superview 
					 animated:YES];
}

- (IBAction) emailPDF:(id)sender {
	MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailController setSubject:paper.title];
	[mailController setMessageBody:[NSString stringWithFormat:@"%@\n\n%@",
									paper.citation,
									paper.doiLink]
							isHTML:NO];
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

- (IBAction) saveOffline:(id)sender {
	[paper save];
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
		case 2:
			[self saveOffline:self];
			break;
		default:
			break;
	}
}

#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"downloadStatus"])
		[self configureView];
	else if ([keyPath isEqualToString:@"downloadProgress"])
		progressIndicator.progress = paper.downloadProgress;
}

#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex {
	[self displayPageNumber:pageIndex + 1];
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	if (paper && paper.downloadStatus == StatusDownloaded) {
		CGPDFDocumentRef aPdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:paper.localPDFPath]);
		NSUInteger ret = CGPDFDocumentGetNumberOfPages(aPdf);
		CGPDFDocumentRelease(aPdf);
		return ret;
	} else {
		return 0;
	}
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	if (paper && paper.downloadStatus == StatusDownloaded) {
		
		CGPDFDocumentRef aPdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:paper.localPDFPath]);
		
		CGPDFPageRef page = CGPDFDocumentGetPage(aPdf, index + 1);
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
		
		CGPDFDocumentRelease(aPdf);
	}
}

#pragma mark UISplitViewControllerDelegate methods

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
	masterButton = barButtonItem;
	[self configureMasterButton];
}


- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:NO];
    [items release];
    self.popoverController = nil;
	masterButton = nil;
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
	leavesView.backgroundRendering = YES;
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
	
	downloadingView.layer.cornerRadius = 16.0;
	
	[self configureForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidUnload {
    self.popoverController = nil;
}

@end
