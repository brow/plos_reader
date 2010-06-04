//
//  RootViewController.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "PaperCell.h"

@class PaperViewController;

@interface FeedViewController : UITableViewController <UIActionSheetDelegate> {
	Feed *feed;
    PaperViewController *detailViewController;
	PaperCell *paperCell;
	UIBarButtonItem *actionsButton;
	UIView *headerView;
}

@property (nonatomic, retain) IBOutlet PaperViewController *detailViewController;
@property (assign) IBOutlet PaperCell *paperCell;
@property (assign) IBOutlet UIView *headerView;

- (id) initWithFeed:(Feed *)aFeed;
- (IBAction) reloadFeed:(id)sender;

@end
