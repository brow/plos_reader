//
//  PubsViewController.m
//  Reader
//
//  Created by Tom Brow on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PubsViewController.h"
#import "FeedViewController.h"
#import "SavedViewController.h"
#import "Feed.h"
#import "JournalCell.h"

enum {SectionFolders, SectionJournals, NumSections};

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
    return NumSections;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case SectionFolders: return 1;
		case SectionJournals: return feeds.count;
		default: return 0;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == SectionJournals) {
		NSString *cellIdentifier = @"JournalCell";
		
		JournalCell *cell = (JournalCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil)
			cell = [[[JournalCell alloc] initWithReuseIdentifier:cellIdentifier] autorelease];
		
		cell.feed = [feeds objectAtIndex:indexPath.row];
		return cell;
	} else {
		NSString *cellIdentifier = @"FolderCell";
		
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil)
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		
		cell.textLabel.text = @"Saved Articles";
		cell.imageView.image = [UIImage imageNamed:@"Folder.png"];
		return cell;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == SectionJournals)
		return @"Journals";
	else
		return nil;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == SectionJournals) {
		Feed *feed = [feeds objectAtIndex:indexPath.row];
		FeedViewController *viewController = [[[FeedViewController alloc] initWithFeed:feed] autorelease];
		viewController.detailViewController = self.detailViewController;
		[self.navigationController pushViewController:viewController animated:YES];
	} else {
		SavedViewController *vc = [[[SavedViewController alloc] init] autorelease];
		vc.detailViewController = self.detailViewController;
		[self.navigationController pushViewController:vc animated:YES];
	}
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

