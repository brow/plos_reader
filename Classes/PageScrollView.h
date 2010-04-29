//
//  PageScrollView.h
//  Reader
//
//  Created by Tom Brow on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeavesView.h"

@interface PageScrollView : UIScrollView {
	LeavesView *leavesView;
}

@property (retain) LeavesView *leavesView;

@end
