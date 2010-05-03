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
#import "Reachability.h"

@implementation ReaderAppDelegate

@synthesize window, splitViewController, rootViewController, paperViewController;

- (void)dealloc {
    [splitViewController release];
    [window release];
    [super dealloc];
}

#pragma mark UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
        
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];
	
	if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Connection Failed" 
														 message:@"An internet connection is required to download new journal articles." 
														delegate:nil 
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil] autorelease];
		[alert show];
	}
	
	if (!paperViewController.paper)
		[paperViewController showMasterPopover];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}


@end

