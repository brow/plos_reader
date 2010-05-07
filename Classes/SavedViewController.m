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

@implementation SavedViewController

@synthesize paperCell, detailViewController;

- (id) init
{
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.navigationItem.title = @"Saved Articles";
		papers = [[Paper savedPapers] retain];
	}
	return self;
}


- (void)dealloc {
	[papers release];
    [super dealloc];
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

@end
