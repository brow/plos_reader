//
//  PaperHypertextView.h
//  Reader
//
//  Created by Tom Brow on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Paper.h"

@interface PaperHypertextView : UIWebView <UIWebViewDelegate> {
	Paper *paper;
}

@property (retain) Paper *paper;
@property (assign) CGFloat scrollPosition;

@end
