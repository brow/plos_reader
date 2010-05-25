//
//  PubsViewController.h
//  Reader
//
//  Created by Tom Brow on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperViewController.h"

@interface SubjectsViewController : UITableViewController <UIActionSheetDelegate> {
    PaperViewController *detailViewController;
	NSArray *feeds;
	UIBarButtonItem *actionsButton;
}

@property (nonatomic, retain) IBOutlet PaperViewController *detailViewController;

@end
