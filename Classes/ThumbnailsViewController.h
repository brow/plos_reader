//
//  ThumbnailsViewController.h
//  Reader
//
//  Created by Tom Brow on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Paper.h"
#import "ThumbnailCell.h"

@interface ThumbnailsViewController : UITableViewController {	
	Paper *paper;
	NSMutableArray *thumbnails;
	ThumbnailCell *thumbnailCell;
}

@property (assign) IBOutlet ThumbnailCell *thumbnailCell;

@end
