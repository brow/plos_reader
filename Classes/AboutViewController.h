//
//  AboutViewController.h
//  Reader
//
//  Created by Tom Brow on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface AboutViewController : UIViewController {
	UILabel *aboutJournalLabel;
	UIView *aboutPLoSView;
	UIImageView *journalLogoView;
	
	NSDictionary *journalInfo;
	NSDictionary *journalLogos;
	Feed *feed;
}

@property (assign) IBOutlet UILabel *aboutJournalLabel;
@property (assign) IBOutlet UIView *aboutPLoSView;
@property (assign) IBOutlet UIImageView *journalLogoView;

- (id)initWithFeed:(Feed *)aFeed;
- (IBAction) dismiss:(id)sender;

@end
