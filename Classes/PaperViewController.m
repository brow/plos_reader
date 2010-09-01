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
#import "MagnifierViewController.h"
#import "FigureViewController.h"

@interface PaperViewController () <MagnifierViewControllerDelegate>
@property (nonatomic, retain) UIPopoverController *popoverController;
@end

@implementation PaperViewController

@synthesize toolbar, popoverController, paper, leavesView, downloadingView, pageLabel, 
citationButton, citationLabel, scrollView, innerShadowView, progressIndicator, downloadingTitleLabel,
magnifyButton, thumbnailsButton, hypertextView, activityIndicator;

- (void)dealloc {
	[hypertextView release];
    [popoverController release];
    [toolbar release];
	[citationLabel release];
	[pageLabel release];
	[leavesView release];
	[downloadingView release];
	[progressIndicator release];
	[activityIndicator release];
	[citationButton release];
	[scrollView release];
	[innerShadowView release];
	[downloadingTitleLabel release];
	[magnifyButton release];
	[thumbnailsButton release];
    
	
	CGPDFDocumentRelease(pdfDoc);
    [paper release];
    [super dealloc];
}

- (BOOL) hypertextEnabled {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hypertext_preference"];
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

- (void) loadPDF {
	if (paper.downloadStatus == StatusDownloaded) {
		@synchronized (self) {
			CGPDFDocumentRelease(pdfDoc);
			pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:paper.localPDFPath]);
		}
	}
}

- (void)configureView {
	if (!paper || paper.downloadStatus == StatusFailed) {
		leavesView.hidden = YES;
		hypertextView.hidden = YES;
		pageLabel.alpha = 0;
		citationLabel.alpha = 0;
		citationButton.alpha = 0;
		magnifyButton.alpha = 0;
		thumbnailsButton.alpha = 0;
		downloadingView.hidden = YES;
	}
	else if (paper.downloadStatus == StatusDownloaded) {
		if ([self hypertextEnabled]) {
			leavesView.hidden = YES;
			hypertextView.hidden = NO;
			thumbnailsButton.hidden = YES;
			pageLabel.hidden = YES;
		}
		else {
			leavesView.hidden = NO;
			hypertextView.hidden = YES;
			thumbnailsButton.hidden = NO;
			pageLabel.hidden = NO;
		}
		[UIView beginAnimations:@"" context:nil];
		[UIView setAnimationDuration:0.4];
		citationButton.alpha = 1;
		citationLabel.alpha = 1;
		pageLabel.alpha = 1;
		magnifyButton.alpha = 1;
		thumbnailsButton.alpha = 1;
		[UIView commitAnimations];
		[self displayPageNumber:leavesView.currentPageIndex+1];
		citationLabel.text = paper.runningHead;
		downloadingView.hidden = NO;
		progressIndicator.hidden = YES;
		activityIndicator.hidden = NO;
	} else {
		leavesView.hidden = YES;
		hypertextView.hidden = YES;
		pageLabel.alpha = 0;
		citationLabel.alpha = 0;
		citationButton.alpha = 0;
		magnifyButton.alpha = 0;
		thumbnailsButton.alpha = 0;
		downloadingView.hidden = NO;
		progressIndicator.hidden = NO;
		activityIndicator.hidden = YES;
	}
	
	downloadingTitleLabel.text = paper.title;
	CGSize titleLabelSize = [downloadingTitleLabel.text sizeWithFont:downloadingTitleLabel.font
												   constrainedToSize:CGSizeMake(downloadingTitleLabel.frame.size.width,
																				75)
													   lineBreakMode:downloadingTitleLabel.lineBreakMode];
	downloadingTitleLabel.frame = CGRectMake(downloadingTitleLabel.frame.origin.x, 
											 downloadingTitleLabel.frame.origin.y, 
											 downloadingTitleLabel.frame.size.width, 
											 titleLabelSize.height);
	
	[self configureMasterButton];
}

- (void) configureForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		scrollView.scrollEnabled = YES;
		innerShadowView.frame = CGRectMake(0, toolbar.frame.size.height, 
										   self.view.bounds.size.width + 100, 
										   self.view.bounds.size.height - toolbar.frame.size.height + 100);
		self.leavesView.preferredTargetWidth = 90;
		magnifyButton.hidden = NO;
	} else {
		scrollView.scrollEnabled = NO;
		innerShadowView.frame = CGRectMake(-100, toolbar.frame.size.height, 
										   self.view.bounds.size.width + 200, 
										   self.view.bounds.size.height - toolbar.frame.size.height + 100);
		self.leavesView.preferredTargetWidth = 180;
		magnifyButton.hidden = YES;
	}
}

- (void) showMasterPopover {
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
		[masterButton.target performSelector:masterButton.action];
}

#pragma mark accessors

- (NSUInteger)page {
    return leavesView.currentPageIndex;
}

- (void)setPage:(NSUInteger)value {
	currentPage = value;
    leavesView.currentPageIndex = value;
	[self displayPageNumber:value+1];
}

- (void)setPaper:(id)newDetailItem {
    if (paper != newDetailItem) {	
		[paper removeObserver:self forKeyPath:@"downloadStatus"];
		[paper removeObserver:self forKeyPath:@"downloadProgress"];
		[paper cancelLoad];
		
        [paper release];
        paper = [newDetailItem retain];
		currentPage = 0;
		
		[paper addObserver:self 
				forKeyPath:@"downloadStatus" 
				   options:NSKeyValueObservingOptionNew 
				   context:nil];
		[paper addObserver:self 
				forKeyPath:@"downloadProgress" 
				   options:NSKeyValueObservingOptionNew 
				   context:nil];
		
		[self loadPDF];
		[self.leavesView reloadData];
		[self configureView];
		hypertextView.paper = paper;
		if (paper.downloadStatus != StatusDownloaded)
			[paper load];
    }
	
    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}

#pragma mark actions

- (IBAction) toggleMagnification:(id)sender {
	MagnifierViewController *vc = [[[MagnifierViewController alloc] initWithParentViewController:self] autorelease];
	[vc view];
	vc.page = self.page;
	vc.delegate = self;
	vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentModalViewController:vc animated:YES];
}

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
	[mailController setMessageBody:[NSString stringWithFormat:@"%@\n\nView online at: %@",
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

- (IBAction) toggleThumbnails:(id)sender {
	ThumbnailsViewController *vc = [[[ThumbnailsViewController alloc] initWithPaper:self.paper 
																  selectedPageIndex:self.page] autorelease];
	vc.delegate = self;
	
	if (self.popoverController)
		[self.popoverController dismissPopoverAnimated:YES];
	
	self.popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
	self.popoverController.popoverContentSize = CGSizeMake(150, 1000);
	[self.popoverController presentPopoverFromRect:thumbnailsButton.frame 
											inView:thumbnailsButton.superview 
						  permittedArrowDirections:UIPopoverArrowDirectionUp 
										  animated:YES];
}

#pragma mark PaperHypertextViewDelegate methods

- (void) paperHypertextView:(PaperHypertextView *)paperHypertextView selectedImageAtURL:(NSURL *)imageURL rect:(CGRect)rect {
	FigureViewController *vc = [[[FigureViewController alloc] init] autorelease];
	NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
	vc.figureImage = [UIImage imageWithData:imageData];
	
	if (self.popoverController)
		[self.popoverController dismissPopoverAnimated:YES];
	
	self.popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
	[self.popoverController presentPopoverFromRect:rect
											inView:hypertextView
						  permittedArrowDirections:UIPopoverArrowDirectionAny
										  animated:YES];
}

- (void) paperHypertextView:(PaperHypertextView *)paperHypertextView selectedEmailAddress:(NSString *)emailAddress rect:(CGRect)rect {
	MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailController setToRecipients:[NSArray arrayWithObject:emailAddress]];
	[mailController setSubject:paper.title];
	mailController.mailComposeDelegate = self;
	[self presentModalViewController:mailController animated:YES];
}

#pragma mark MagnifierViewControllerDelegate methods

- (void) magnifierViewControllerDidFinish:(MagnifierViewController *)magnifierViewController {
	[self view];
	self.page = magnifierViewController.page;
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark ThumbnailsViewControllerDelegate methods

- (void) thumbnailsViewController:(ThumbnailsViewController *)viewController didSelectPageIndex:(NSUInteger)pageIndex {
	self.page = pageIndex;
	[self.popoverController dismissPopoverAnimated:YES];
	self.popoverController = nil;
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
	if ([keyPath isEqualToString:@"downloadStatus"]) {
		[self loadPDF];
		if (paper.downloadStatus == StatusDownloaded)
			[self.leavesView reloadData];
		[self configureView];
	}
	else if ([keyPath isEqualToString:@"downloadProgress"])
		progressIndicator.progress = paper.downloadProgress;
}

#pragma mark  LeavesViewDelegate methods

- (void) leavesView:(LeavesView *)aLeavesView willTurnToPageAtIndex:(NSUInteger)pageIndex {
	[self displayPageNumber:pageIndex + 1];
	if (pageIndex == currentPage + 1) {
		[UIView beginAnimations:@"scrollToTop" context:nil];
		[UIView setAnimationDuration:0.5];
		scrollView.contentOffset = CGPointMake(0, 0);
		[UIView commitAnimations];
	}
}

- (void) leavesView:(LeavesView *)aLeavesView didTurnToPageAtIndex:(NSUInteger)pageIndex {
	currentPage = pageIndex;
}

#pragma mark LeavesViewDataSource methods

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView {
	if (paper && paper.downloadStatus == StatusDownloaded) {
		NSUInteger numPages;
		@synchronized (self) {
			numPages = CGPDFDocumentGetNumberOfPages(pdfDoc);
		}
		return numPages;
	} else {
		return 0;
	}
}

- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx {
	if (paper && paper.downloadStatus == StatusDownloaded) {
		@synchronized (self) {
			
			CGPDFPageRef page = CGPDFDocumentGetPage(pdfDoc, index + 1);
			CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);		
			CGRect croppedRect = CGRectInset(pageRect, 44, 44); 
			croppedRect.origin.y += 1;
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
}

#pragma mark UISplitViewControllerDelegate methods

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    if (!masterButton) {
		NSMutableArray *items = [[toolbar items] mutableCopy];
		[items insertObject:barButtonItem atIndex:0];
		[toolbar setItems:items animated:YES];
		[items release];
		masterButton = barButtonItem;
	}
    self.popoverController = pc;
	[self configureMasterButton];
}


- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    if (masterButton) {
		NSMutableArray *items = [[toolbar items] mutableCopy];
		[items removeObjectAtIndex:0];
		[toolbar setItems:items animated:NO];
		[items release];
		masterButton = nil;
	}
    self.popoverController = nil;
}

#pragma mark UIViewController methods

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	[self.leavesView.cache flush];
	
	/* Release and re-create the CGPDFDocument to flush its cache. */
	[self loadPDF];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[citationActionSheet dismissWithClickedButtonIndex:2 animated:YES];
	scrollView.contentSize = leavesView.frame.size;
	[self configureForInterfaceOrientation:interfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (!self.paper)
		[self showMasterPopover];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	leavesView.dataSource = self;
	leavesView.delegate = self;
	leavesView.backgroundRendering = YES;
	if (paper && paper.downloadStatus == StatusDownloaded)
		[leavesView reloadData];
	
	hypertextView.hypertextDelegate = self;
	
	[self configureView];
	
	UIImage *buttonBackground = [[UIImage imageNamed:@"CitationButton.png"] stretchableImageWithLeftCapWidth:10 
																								topCapHeight:10];
	UIImage *buttonHighlightedBackground = [[UIImage imageNamed:@"CitationButtonHighlighted.png"] stretchableImageWithLeftCapWidth:10 
																													  topCapHeight:10];
	[citationButton setBackgroundImage:buttonBackground
							  forState:UIControlStateNormal];
	[citationButton setBackgroundImage:buttonHighlightedBackground
							  forState:UIControlStateHighlighted];
	[thumbnailsButton setBackgroundImage:buttonBackground
								forState:UIControlStateNormal];
	[thumbnailsButton setBackgroundImage:buttonHighlightedBackground
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
