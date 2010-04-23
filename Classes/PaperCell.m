//
//  PaperCell.m
//  Reader
//
//  Created by Tom Brow on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PaperCell.h"


@implementation PaperCell

@synthesize paper;

- (void) awakeFromNib {
	titleLabel.highlightedTextColor = [UIColor whiteColor];
	authorLabel.highlightedTextColor = [UIColor whiteColor];
}

- (void)dealloc {
	[titleLabel release];
	[authorLabel release];
    [super dealloc];
}

#pragma mark properties

- (void) setPaper:(Paper *)aPaper {
	[paper autorelease];
	paper = [aPaper retain];
	
	titleLabel.text = paper.title;
	authorLabel.text = paper.authors;
	
	CGSize titleSize = [paper.title sizeWithFont:titleLabel.font 
							   constrainedToSize:CGSizeMake(titleLabel.frame.size.width, 63)
								   lineBreakMode:titleLabel.lineBreakMode];
	
	titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, 
								  titleLabel.frame.origin.y, 
								  titleLabel.frame.size.width, 
								  titleSize.height);
}

#pragma mark UITableViewCell methods

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}

- (NSString *) reuseIdentifier {
	return @"PaperCell";
}


@end
