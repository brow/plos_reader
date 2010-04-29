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

@interface PaperViewController : UIViewController 
<UIPopoverControllerDelegate, UISplitViewControllerDelegate, LeavesViewDelegate, 
LeavesViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,
UINavigationControllerDelegate> {
    
	PageScrollView *scrollView;
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
	UIActivityIndicatorView *activityIndicator;
	LeavesView *leavesView;
	UILabel *pageLabel;
	UIButton *citationButton;
	UILabel *citationLabel;
	UIActionSheet *citationActionSheet;
	UIImageView *innerShadowView;
    
    Paper *paper;
	CGPDFDocumentRef pdf;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (assign) IBOutlet LeavesView *leavesView;
@property (assign) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (assign) IBOutlet UILabel *pageLabel;
@property (assign) IBOutlet UIButton *citationButton;
@property (assign) IBOutlet UILabel *citationLabel;
@property (assign) IBOutlet PageScrollView *scrollView;
@property (assign) IBOutlet UIImageView *innerShadowView;

@property (nonatomic, retain) Paper *paper;

- (IBAction) showCitationActions:(id)sender;

@end
