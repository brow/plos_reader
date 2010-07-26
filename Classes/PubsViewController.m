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
#import "SubjectsViewController.h"
#import "Feed.h"
#import "JournalCell.h"
#import "Paper+Saving.h"

enum {SectionFolders, SectionJournals, NumSections};

@implementation PubsViewController

@synthesize detailViewController;

- (void) awakeFromNib
{
	[super awakeFromNib];
	self.navigationItem.title = @"";
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Journals" 
																			  style:UIBarButtonItemStyleBordered 
																			 target:nil 
																			 action:nil] autorelease];
	self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	feeds = [[Feed journalFeeds] retain];
	
	[[Paper savedPapersManager] addObserver:self 
								 forKeyPath:@"savedPapers" 
									options:NSKeyValueObservingOptionNew
									context:nil];
	
	for (Feed *feed in feeds)
		[feed load];
}


- (void)dealloc {
	[[Paper savedPapersManager] removeObserver:self 
									forKeyPath:@"savedPapers"];
	[feeds release];
    [detailViewController release];
	[searchController release];
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
		case SectionFolders: return [Paper savedPapersManager].savedPapers.count > 0 ? 1 : 0;
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	if (section == SectionJournals && [Paper savedPapersManager].savedPapers.count > 0)
//		return @"Journals";
//	else
//		return nil;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == SectionJournals /*&& [Paper savedPapersManager].savedPapers.count > 0*/) {
		UIImageView *imageView = [[[UIImageView alloc] init] autorelease];
		imageView.image =[UIImage imageNamed:@"PLoS_Header.png"];
		imageView.contentMode = UIViewContentModeLeft;
		imageView.backgroundColor = [UIColor darkGrayColor];
		imageView.bounds = CGRectMake(0, 0, 320, 36);
		return imageView;
	}
	else
		return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == SectionJournals) {
		Feed *feed = [feeds objectAtIndex:indexPath.row];
		if (feed.title == @"PLoS ONE") {
			SubjectsViewController *viewController = [[[SubjectsViewController alloc] init] autorelease];
			viewController.detailViewController = self.detailViewController;
			[self.navigationController pushViewController:viewController animated:YES];
		} else {
			FeedViewController *viewController = [[[FeedViewController alloc] initWithFeed:feed] autorelease];
			viewController.detailViewController = self.detailViewController;
			[self.navigationController pushViewController:viewController animated:YES];
		}
	} else {
		SavedViewController *vc = [[[SavedViewController alloc] init] autorelease];
		vc.detailViewController = self.detailViewController;
		[self.navigationController pushViewController:vc animated:YES];
	}
}

#pragma mark UIViewController methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
	searchBar.placeholder = @"Search articles by title";
	self.tableView.tableHeaderView = searchBar;
	
	searchController = [[SearchController alloc] initWithSearchBar:searchBar contentsController:self];
	searchController.detailViewController = self.detailViewController;
}

- (void) viewDidUnload {
	[super viewDidUnload];
	[searchController release];
	searchController = nil;
}

@end

