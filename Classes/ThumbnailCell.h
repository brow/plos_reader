//
//  ThumbnailCell.h
//  Reader
//
//  Created by Tom Brow on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ThumbnailCell : UITableViewCell {
	UILabel *pageNumberLabel;
	UIImageView *thumbImageView;
}

@property (assign) IBOutlet UILabel *pageNumberLabel;
@property (assign) IBOutlet UIImageView *thumbImageView;

@end
