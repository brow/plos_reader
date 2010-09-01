//
//  CitationViewController.h
//  Reader
//
//  Created by Tom Brow on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Citation.h"

@interface CitationViewController : UIViewController {
	UITextView *textView;
	Citation *citation;
}

@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain) Citation *citation;

@end
