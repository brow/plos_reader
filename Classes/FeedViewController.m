//
//  RootViewController.m
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FeedViewController.h"
#import "PaperViewController.h"
#import "Paper.h"
#import "AboutViewController.h"

@implementation FeedViewController

@synthesize detailViewController, paperCell;

- (id) initWithFeed:(Feed *)aFeed
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		feed = [aFeed retain];
		[feed addObserver:self 
			   forKeyPath:@"papers" 
				  options:NSKeyValueObservingOptionNew 
				  context:nil];
		[feed addObserver:self 
			   forKeyPath:@"downloaded" 
				  options:NSKeyValueObservingOptionNew 
				  context:nil];		
		
		actionsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FeedActions.png"] 
														 style:UIBarButtonItemStylePlain
														target:self 
														action:@selector(showActions:)];
		
		self.navigationItem.title = feed.title;
		self.clearsSelectionOnViewWillAppear = NO;
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	}
	return self;
}


- (void)dealloc {
	[feed removeObserver:self 
			  forKeyPath:@"papers"];
	[feed removeObserver:self 
			  forKeyPath:@"downloaded"];
	
	[feed release];
    [detailViewController release];
	[actionsButton release];
    [super dealloc];
}

- (void)displayFeedStatus {
	if (feed.downloaded) {
		[self.navigationItem setRightBarButtonItem:actionsButton animated:YES];
	} else {
		UIActivityIndicatorView *activityIndicator = 
			[[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		[activityIndicator startAnimating];
		UIBarButtonItem *barButtonItem =
			[[[UIBarButtonItem alloc] initWithCustomView:activityIndicator] autorelease];
		[self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
	}
}

#pragma mark actions

- (IBAction) showActions:(id)sender {
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
															  delegate:self 
													 cancelButtonTitle:nil  
												destructiveButtonTitle:nil 
													 otherButtonTitles:@"Refresh Articles",@"About This Journal",nil] autorelease];
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		[actionSheet addButtonWithTitle:@"Cancel"];
		actionSheet.cancelButtonIndex = 2;
	}
	
	[actionSheet showFromBarButtonItem:actionsButton animated:YES];
	
	/* Nav bar buttons still receive touches for some reason. */
	self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (IBAction) showAbout:(id)sender {
	UIViewController *vc = [[[AboutViewController alloc] initWithFeed:feed] autorelease];
	vc.modalPresentationStyle = UIModalPresentationFormSheet;
	vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
 	[self.splitViewController presentModalViewController:vc animated:YES];
}

- (IBAction) reloadFeed:(id)sender {
	[feed load];
}

#pragma mark UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	self.navigationController.navigationBar.userInteractionEnabled = YES;
	switch (buttonIndex) {
		case 0:
			[self reloadFeed:self];
			break;
		case 1:
			[self showAbout:self];
			break;
		default:
			break;
	}
}

#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"downloaded"])
		[self displayFeedStatus];
	else
		[self.tableView reloadData];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return feed.papers.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"PaperCell";
    
    PaperCell *cell = (PaperCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"PaperCell" 
									  owner:self 
									options:nil];
        cell = self.paperCell;
    }
	
	cell.paper = [feed.papers objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    detailViewController.paper = [feed.papers objectAtIndex:indexPath.row];
}

#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
	[self displayFeedStatus];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end

