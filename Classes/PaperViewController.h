//
//  DetailViewController.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeavesView.h"
#import "Paper.h"

@interface PaperViewController : UIViewController 
<UIPopoverControllerDelegate, UISplitViewControllerDelegate, LeavesViewDelegate, LeavesViewDataSource> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
	UIActivityIndicatorView *activityIndicator;
	LeavesView *leavesView;
	UILabel *pageLabel;
    
    Paper *paper;
	CGPDFDocumentRef pdf;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (assign) IBOutlet LeavesView *leavesView;
@property (assign) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (assign) IBOutlet UILabel *pageLabel;

@property (nonatomic, retain) Paper *paper;

@end
