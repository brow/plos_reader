//
//  ThumbnailCell.m
//  Reader
//
//  Created by Tom Brow on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ThumbnailCell

@synthesize pageNumberLabel, thumbImageView;

- (void) awakeFromNib {
	[super awakeFromNib];
	self.selectionStyle = UITableViewCellSelectionStyleGray;
	
	UIView *selectedBackground = [[[UIView alloc] init] autorelease];
	selectedBackground.backgroundColor = [UIColor whiteColor];
	selectedBackground.layer.cornerRadius = 8;
	self.selectedBackgroundView = selectedBackground;
	
	pageNumberLabel.highlightedTextColor = [UIColor blackColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	thumbImageView.backgroundColor = [UIColor whiteColor];
}

@end
