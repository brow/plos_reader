//
//  SearchTableViewDelegate.h
//  Reader
//
//  Created by Tom Brow on 6/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperCell.h"
#import "SearchArchiveCell.h"
#import "ASINetworkQueue.h"
#import "PaperViewController.h"

@interface SearchController : UISearchDisplayController 
<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>
{
	PaperCell *paperCell;
	SearchArchiveCell *searchArchiveCell;
	PaperViewController *detailViewController;
	
	ASINetworkQueue *networkQueue;
	NSMutableArray *results;
	BOOL didSearchOnServer;
	NSString *responsePath;
}

@property (nonatomic, retain) IBOutlet PaperViewController *detailViewController;
@property (assign) IBOutlet PaperCell *paperCell;
@property (assign) IBOutlet SearchArchiveCell *searchArchiveCell;

@end
