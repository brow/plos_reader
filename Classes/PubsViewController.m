//
//  PubsViewController.m
//  Reader
//
//  Created by Tom Brow on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PubsViewController.h"
#import "FeedViewController.h"
#import "Feed.h"
#import "JournalCell.h"

@implementation PubsViewController


@synthesize detailViewController;

- (void) awakeFromNib
{
	[super awakeFromNib];
	self.title = @"Journals";
	feeds = [[NSArray alloc] initWithObjects:
			 [Feed feedWithTitle:@"Biology" 
							 URL:@"http://www.plosbiology.org/article/feed" 
					   imageName:@"PLoS_Biology.png"], 
			 [Feed feedWithTitle:@"Medicine" 
							 URL:@"http://www.plosmedicine.org/article/feed" 
					   imageName:@"PLoS_Medicine.png"], 
			 [Feed feedWithTitle:@"Genetics" 
							 URL:@"http://www.plosgenetics.org/article/feed" 
					   imageName:@"PLoS_Genetics.png"], 
			 [Feed feedWithTitle:@"Pathogens" 
							 URL:@"http://www.plospathogens.org/article/feed" 
					   imageName:@"PLoS_Pathogens.png"],
			 [Feed feedWithTitle:@"Computational Biology" 
							 URL:@"http://www.ploscompbiol.org/article/feed" 
					   imageName:@"PLoS_CompBio.png"], 
			 [Feed feedWithTitle:@"Neglected Tropical Diseases" 
							 URL:@"http://www.plosntds.org/article/feed" 
					   imageName:@"PLoS_NTD.png"],
			 [Feed feedWithTitle:@"ONE" 
							 URL:@"http://feeds.plos.org/plosone/PLoSONE" 
					   imageName:@"PLoS_One.png"],
			 nil];
}


- (void)dealloc {
	[feeds release];
    [detailViewController release];
    [super dealloc];
}

#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self.tableView reloadData];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return feeds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"JournalCell";
    
    JournalCell *cell = (JournalCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[[JournalCell alloc] initWithReuseIdentifier:cellIdentifier] autorelease];
	
	cell.feed = [feeds objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Feed *feed = [feeds objectAtIndex:indexPath.row];
	FeedViewController *viewController = [[[FeedViewController alloc] initWithFeed:feed] autorelease];
	viewController.detailViewController = self.detailViewController;
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	for (Feed *feed in feeds)
		[feed load];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end

