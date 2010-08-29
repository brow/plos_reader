//
//  DetailViewController.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LeavesView.h"
#import "PageScrollView.h"
#import "Paper.h"
#import "ThumbnailsViewController.h"
#import "PaperHypertextView.h"

@interface PaperViewController : UIViewController 
<UIPopoverControllerDelegate, UISplitViewControllerDelegate, LeavesViewDelegate, 
LeavesViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,
UINavigationControllerDelegate, ThumbnailsViewControllerDelegate> {
    
	PaperHypertextView *hypertextView;
	PageScrollView *scrollView;
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
	UIView *downloadingView;
	UILabel *downloadingTitleLabel;
	UIProgressView *progressIndicator;
	UIActivityIndicatorView *activityIndicator;
	LeavesView *leavesView;
	UILabel *pageLabel;
	UIButton *citationButton;
	UILabel *citationLabel;
	UIActionSheet *citationActionSheet;
	UIImageView *innerShadowView;
	UIBarButtonItem *masterButton;
	UIButton *magnifyButton;
	UIButton *thumbnailsButton;
	
	CGPDFDocumentRef pdfDoc;
    Paper *paper;
	NSUInteger currentPage;
}

@property (nonatomic, retain) IBOutlet PaperHypertextView *hypertextView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel *citationLabel;
@property (nonatomic, retain) IBOutlet UILabel *pageLabel;
@property (nonatomic, retain) IBOutlet LeavesView *leavesView;
@property (nonatomic, retain) IBOutlet UIView *downloadingView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressIndicator;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIButton *citationButton;
@property (nonatomic, retain) IBOutlet PageScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *innerShadowView;
@property (nonatomic, retain) IBOutlet UILabel *downloadingTitleLabel;
@property (nonatomic, retain) IBOutlet UIButton *magnifyButton;
@property (nonatomic, retain) IBOutlet UIButton *thumbnailsButton;

@property (nonatomic, retain) Paper *paper;
@property (assign) NSUInteger page;

- (IBAction) toggleMagnification:(id)sender;
- (IBAction) showCitationActions:(id)sender;
- (void) showMasterPopover;
- (IBAction) toggleThumbnails:(id)sender;

@end
