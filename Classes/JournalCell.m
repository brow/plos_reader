//
//  JournalCell.m
//  Reader
//
//  Created by Tom Brow on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JournalCell.h"


@implementation JournalCell

@synthesize feed;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		imageView = [[UIImageView alloc] init];
		imageView.frame = self.contentView.frame;
		imageView.contentMode = UIViewContentModeCenter;
		imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:imageView];
    }
    return self;
}

- (void)dealloc {
	[imageView release];
	[feed release];
    [super dealloc];
}

#pragma mark properties

- (void) setFeed:(Feed*)aFeed {
	[feed autorelease];
	feed = [aFeed retain];
	imageView.image = feed.image;
}

@end
