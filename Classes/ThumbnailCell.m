//
//  ThumbnailCell.m
//  Reader
//
//  Created by Tom Brow on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailCell.h"


@implementation ThumbnailCell

@synthesize pageNumberLabel, thumbImageView;

- (void) awakeFromNib {
	[super awakeFromNib];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
