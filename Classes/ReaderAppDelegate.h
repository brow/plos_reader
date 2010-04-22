//
//  ReaderAppDelegate.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class FeedViewController;
@class PaperViewController;

@interface ReaderAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    FeedViewController *rootViewController;
    PaperViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet FeedViewController *rootViewController;
@property (nonatomic, retain) IBOutlet PaperViewController *detailViewController;

@end
