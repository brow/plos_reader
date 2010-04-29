//
//  JournalCell.h
//  Reader
//
//  Created by Tom Brow on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface JournalCell : UITableViewCell {
	UIImageView *imageView;
	Feed *feed;
}

@property (retain) Feed *feed;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
