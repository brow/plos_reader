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

@interface PaperViewController : UIViewController 
<UIPopoverControllerDelegate, UISplitViewControllerDelegate, LeavesViewDelegate, 
LeavesViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,
UINavigationControllerDelegate, ThumbnailsViewControllerDelegate> {
    
	PageScrollView *scrollView;
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
	UIView *downloadingView;
	UILabel *downloadingTitleLabel;
	UIProgressView *progressIndicator;
	LeavesView *leavesView;
	UILabel *pageLabel;
	UIButton *citationButton;
	UILabel *citationLabel;
	UIActionSheet *citationActionSheet;
	UIImageView *innerShadowView;
	UIBarButtonItem *masterButton;
	UIButton *magnifyButton;
	UIButton *thumbnailsButton;
    
    Paper *paper;
	NSUInteger currentPage;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (assign) IBOutlet LeavesView *leavesView;
@property (assign) IBOutlet UIView *downloadingView;
@property (assign) IBOutlet UIProgressView *progressIndicator;
@property (assign) IBOutlet UILabel *pageLabel;
@property (assign) IBOutlet UIButton *citationButton;
@property (assign) IBOutlet UILabel *citationLabel;
@property (assign) IBOutlet PageScrollView *scrollView;
@property (assign) IBOutlet UIImageView *innerShadowView;
@property (assign) IBOutlet UILabel *downloadingTitleLabel;
@property (assign) IBOutlet UIButton *magnifyButton;
@property (assign) IBOutlet UIButton *thumbnailsButton;

@property (nonatomic, retain) Paper *paper;
@property (assign) NSUInteger page;

- (IBAction) toggleMagnification:(id)sender;
- (IBAction) showCitationActions:(id)sender;
- (void) showMasterPopover;
- (IBAction) toggleThumbnails:(id)sender;

@end
