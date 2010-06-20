//
//  SearchArchiveCell.h
//  Reader
//
//  Created by Tom Brow on 6/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchArchiveCell : UITableViewCell {
	UILabel *label;
	UIActivityIndicatorView *activityIndicator;
	BOOL active;
}

@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (assign) BOOL active;

@end
