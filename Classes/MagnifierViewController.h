//
//  MagnifierViewController.h
//  Reader
//
//  Created by Tom Brow on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PaperViewController.h"

@interface  MagnifierViewController : PaperViewController {
	id delegate;
}

@property (assign) id delegate;

- (id)initWithPaper:(Paper *)aPaper;

@end
