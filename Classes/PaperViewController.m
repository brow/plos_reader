//
//  DetailViewController.m
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "PaperViewController.h"
#import "FeedViewController.h"


@interface PaperViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation PaperViewController

@synthesize toolbar, popoverController, detailItem, detailDescriptionLabel;

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
    [detailItem release];
    [detailDescriptionLabel release];
    [super dealloc];
}

- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [newDetailItem retain];
		[self configureView];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }        
}


- (void)configureView {
    detailDescriptionLabel.text = [detailItem description];   
}


#pragma mark UISplitViewControllerDelegate methods

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    barButtonItem.title = @"Papers";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {

    self.popoverController = nil;
}

@end
