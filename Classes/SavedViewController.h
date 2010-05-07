//
//  SavedViewController.h
//  Reader
//
//  Created by Tom Brow on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperCell.h"
#import "PaperViewController.h"

@interface SavedViewController : UITableViewController {
	NSMutableArray *papers;
	PaperCell *paperCell;
	PaperViewController *detailViewController;
}

@property (assign) IBOutlet PaperCell *paperCell;
@property (nonatomic, retain) IBOutlet PaperViewController *detailViewController;

@end
