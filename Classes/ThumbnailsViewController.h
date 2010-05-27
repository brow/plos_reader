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

@protocol ThumbnailsViewControllerDelegate;


@interface ThumbnailsViewController : UITableViewController {	
	Paper *paper;
	NSUInteger selectedPageIndex;
	
	NSMutableArray *thumbnails;
	ThumbnailCell *thumbnailCell;
	id<ThumbnailsViewControllerDelegate> delegate;
}

@property (assign) IBOutlet ThumbnailCell *thumbnailCell;
@property (assign) id<ThumbnailsViewControllerDelegate> delegate;

- (id)initWithPaper:(Paper *)aPaper selectedPageIndex:(NSUInteger)pageIndex;

@end


@protocol ThumbnailsViewControllerDelegate

- (void) thumbnailsViewController:(ThumbnailsViewController *)viewController didSelectPageIndex:(NSUInteger)pageIndex;

@end;