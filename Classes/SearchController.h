//
//  SearchTableViewDelegate.h
//  Reader
//
//  Created by Tom Brow on 6/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperCell.h"

@interface SearchController : UISearchDisplayController 
<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>
{
	PaperCell *paperCell;
	
	
	NSMutableArray *results;
	NSString *responsePath;
}

@property (assign) IBOutlet PaperCell *paperCell;

@end
