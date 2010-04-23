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

@interface FeedViewController : UITableViewController {
	Feed *feed;
    PaperViewController *detailViewController;
	PaperCell *paperCell;
}

@property (nonatomic, retain) IBOutlet PaperViewController *detailViewController;
@property (assign) IBOutlet PaperCell *paperCell;

- (id) initWithFeed:(Feed *)aFeed;

@end
