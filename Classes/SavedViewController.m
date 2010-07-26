//
//  SavedViewController.m
//  Reader
//
//  Created by Tom Brow on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SavedViewController.h"
#import "Paper+Saving.h"
#import "PaperCell.h"
#import "Utilities.h"

@implementation SavedViewController

@synthesize paperCell, detailViewController;

- (id) init
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.navigationItem.title = @"Saved Articles";
		papers = [[NSMutableArray alloc] init];
		
		[[Paper savedPapersManager] addObserver:self 
									 forKeyPath:@"savedPapers" 
										options:NSKeyValueObservingOptionNew
										context:nil];
	}
	return self;
}


- (void)dealloc {
	[[Paper savedPapersManager] removeObserver:self 
									forKeyPath:@"savedPapers"];
	[papers release];
    [super dealloc];
}

- (void) reload {
	NSArray *unsortedPapers = [[[Paper savedPapersManager] savedPapers] allObjects];
	[papers setArray:[unsortedPapers sortedArrayUsingFunction:dateSort context:nil]];
}

#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeInsertion) {
		[self reload];
		
		/* We assume that only one object was inserted (as only one paper can be saved at a time). */
		id insertedObject = [[change objectForKey:NSKeyValueChangeNewKey] anyObject];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[papers indexOfObject:insertedObject] 
													inSection:0];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							  withRowAnimation:UITableViewRowAnimationTop];
	}
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return papers.count;
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
	
	cell.paper = [papers objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    detailViewController.paper = [papers objectAtIndex:indexPath.row];
}


- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[papers objectAtIndex:indexPath.row] unsave];
		[papers removeObjectAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
							  withRowAnimation:YES];
	}
}


#pragma mark UIViewController methods

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	[self reload];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end