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
#import "Paper+Saving.h"

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
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Offline Mode" 
														 message:@"Only saved articles will be available. To download new articles, check your internet connection and reopen PLoS Reader." 
														delegate:nil 
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil] autorelease];
		[alert show];
	}
	
	if ([Paper autosavedPaper]) {
		paperViewController.paper = [Paper autosavedPaper];
		paperViewController.page = [[NSUserDefaults standardUserDefaults] integerForKey:@"autosavedPage"];
	}
	
	if (!paperViewController.paper)
		[paperViewController showMasterPopover];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	if (paperViewController.paper) {
		[paperViewController.paper autosave];
		[[NSUserDefaults standardUserDefaults] setInteger:paperViewController.page 
												   forKey:@"autosavedPage"];
	}
	
}


@end

