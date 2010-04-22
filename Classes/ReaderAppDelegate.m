//
//  ReaderAppDelegate.m
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ReaderAppDelegate.h"


#import "FeedViewController.h"
#import "PaperViewController.h"


@implementation ReaderAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [splitViewController release];
    [window release];
    [super dealloc];
}


@end

