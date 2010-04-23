//
//  PaperCell.h
//  Reader
//
//  Created by Tom Brow on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Paper.h"

@interface PaperCell : UITableViewCell {
	Paper *paper;
	IBOutlet UILabel *titleLabel, *authorLabel;
}

@property (retain) Paper *paper;

@end
