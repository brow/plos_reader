//
//  PubsViewController.h
//  Reader
//
//  Created by Tom Brow on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperViewController.h"

@interface SubjectsViewController : UITableViewController {
    PaperViewController *detailViewController;
	NSArray *feeds;
}

@property (nonatomic, retain) IBOutlet PaperViewController *detailViewController;

@end
