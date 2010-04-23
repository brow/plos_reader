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
		self.navigationItem.title = feed.title;
	}
	return self;
}


- (void)dealloc {
	[feed removeObserver:self 
			  forKeyPath:@"papers" ];
	
	[feed release];
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
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end

