//
//  PubsViewController.m
//  Reader
//
//  Created by Tom Brow on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SubjectsViewController.h"
#import "FeedViewController.h"
#import "Feed.h"
#import "UIColor+Extras.h"

@implementation SubjectsViewController

@synthesize detailViewController;

- (id) init
{
	if (self = [super init]) {
		self.title = @"PLoS ONE";
		feeds = [[NSArray alloc] initWithObjects:
				 [Feed feedWithTitle:@"All Subjects"
								 URL:@"http://www.plosone.org/article/feed?category=Anesthesiology%20and%20Pain%20Management"
						   imageName:nil],
				 [Feed feedWithTitle:@"Anesthesiology and Pain Management"
								 URL:@"http://www.plosone.org/article/feed?category=Anesthesiology%20and%20Pain%20Management"
						   imageName:nil],
				 [Feed feedWithTitle:@"Biochemistry"
								 URL:@"http://www.plosone.org/article/feed?category=Biochemistry"
						   imageName:nil],
				 [Feed feedWithTitle:@"Biophysics"
								 URL:@"http://www.plosone.org/article/feed?category=Biophysics"
						   imageName:nil],
				 [Feed feedWithTitle:@"Biotechnology"
								 URL:@"http://www.plosone.org/article/feed?category=Biotechnology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Cardiovascular Disorders"
								 URL:@"http://www.plosone.org/article/feed?category=Cardiovascular%20Disorders"
						   imageName:nil],
				 [Feed feedWithTitle:@"Cell Biology"
								 URL:@"http://www.plosone.org/article/feed?category=Cell%20Biology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Chemical Biology"
								 URL:@"http://www.plosone.org/article/feed?category=Chemical%20Biology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Chemistry"
								 URL:@"http://www.plosone.org/article/feed?category=Chemistry"
						   imageName:nil],
				 [Feed feedWithTitle:@"Computational Biology"
								 URL:@"http://www.plosone.org/article/feed?category=Computational%20Biology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Computer Science"
								 URL:@"http://www.plosone.org/article/feed?category=Computer%20Science"
						   imageName:nil],
				 [Feed feedWithTitle:@"Critical Care and Emergency Medicine"
								 URL:@"http://www.plosone.org/article/feed?category=Critical%20Care%20and%20Emergency%20Medicine"
						   imageName:nil],
				 [Feed feedWithTitle:@"Dermatology"
								 URL:@"http://www.plosone.org/article/feed?category=Dermatology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Developmental Biology"
								 URL:@"http://www.plosone.org/article/feed?category=Developmental%20Biology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Diabetes and Endocrinology"
								 URL:@"http://www.plosone.org/article/feed?category=Diabetes%20and%20Endocrinology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Ecology"
								 URL:@"http://www.plosone.org/article/feed?category=Ecology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Evidence-Based Healthcare"
								 URL:@"http://www.plosone.org/article/feed?category=Evidence-Based%20Healthcare"
						   imageName:nil],
				 [Feed feedWithTitle:@"Evolutionary Biology"
								 URL:@"http://www.plosone.org/article/feed?category=Evolutionary%20Biology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Gastroenterology and Hepatology"
								 URL:@"http://www.plosone.org/article/feed?category=Gastroenterology%20and%20Hepatology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Genetics and Genomics"
								 URL:@"http://www.plosone.org/article/feed?category=Genetics%20and%20Genomics"
						   imageName:nil],
				 [Feed feedWithTitle:@"Geriatrics"
								 URL:@"http://www.plosone.org/article/feed?category=Geriatrics"
						   imageName:nil],
				 [Feed feedWithTitle:@"Hematology"
								 URL:@"http://www.plosone.org/article/feed?category=Hematology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Immunology"
								 URL:@"http://www.plosone.org/article/feed?category=Immunology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Infectious Diseases"
								 URL:@"http://www.plosone.org/article/feed?category=Infectious%20Diseases"
						   imageName:nil],
				 [Feed feedWithTitle:@"Marine and Aquatic Sciences"
								 URL:@"http://www.plosone.org/article/feed?category=Marine%20and%20Aquatic%20Sciences"
						   imageName:nil],
				 [Feed feedWithTitle:@"Mathematics"
								 URL:@"http://www.plosone.org/article/feed?category=Mathematics"
						   imageName:nil],
				 [Feed feedWithTitle:@"Mental Health"
								 URL:@"http://www.plosone.org/article/feed?category=MentalHealth"
						   imageName:nil],
				 [Feed feedWithTitle:@"Microbiology"
								 URL:@"http://www.plosone.org/article/feed?category=Microbiology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Molecular Biology"
								 URL:@"http://www.plosone.org/article/feed?category=Molecular%20Biology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Nephrology"
								 URL:@"http://www.plosone.org/article/feed?category=Nephrology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Neurological Disorders"
								 URL:@"http://www.plosone.org/article/feed?category=Neurological%20Disorders"
						   imageName:nil],
				 [Feed feedWithTitle:@"Neuroscience"
								 URL:@"http://www.plosone.org/article/feed?category=Neuroscience"
						   imageName:nil],
				 [Feed feedWithTitle:@"Non-Clinical Medicine"
								 URL:@"http://www.plosone.org/article/feed?category=Non-Clinical%20Medicine"
						   imageName:nil],
				 [Feed feedWithTitle:@"Nutrition"
								 URL:@"http://www.plosone.org/article/feed?category=Nutrition"
						   imageName:nil],
				 [Feed feedWithTitle:@"Obstetrics"
								 URL:@"http://www.plosone.org/article/feed?category=Obstetrics"
						   imageName:nil],
				 [Feed feedWithTitle:@"Oncology"
								 URL:@"http://www.plosone.org/article/feed?category=Oncology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Ophthalmology"
								 URL:@"http://www.plosone.org/article/feed?category=Ophthalmology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Otolaryngology"
								 URL:@"http://www.plosone.org/article/feed?category=Otolaryngology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Pathology"
								 URL:@"http://www.plosone.org/article/feed?category=Pathology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Pediatrics and Child Health"
								 URL:@"http://www.plosone.org/article/feed?category=Pediatrics%20and%20Child%20Health"
						   imageName:nil],
				 [Feed feedWithTitle:@"Pharmacology"
								 URL:@"http://www.plosone.org/article/feed?category=Pharmacology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Physics"
								 URL:@"http://www.plosone.org/article/feed?category=Physics"
						   imageName:nil],
				 [Feed feedWithTitle:@"Physiology"
								 URL:@"http://www.plosone.org/article/feed?category=Physiology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Plant Biology"
								 URL:@"http://www.plosone.org/article/feed?category=Plant%20Biology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Public Health and Epidemiology"
								 URL:@"http://www.plosone.org/article/feed?category=Public%20Health%20and%20Epidemiology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Radiology and Medical Imaging"
								 URL:@"http://www.plosone.org/article/feed?category=Radiology%20and%20Medical%20Imaging"
						   imageName:nil],
				 [Feed feedWithTitle:@"Respiratory Medicine"
								 URL:@"http://www.plosone.org/article/feed?category=Respiratory%20Medicine"
						   imageName:nil],
				 [Feed feedWithTitle:@"Rheumatology"
								 URL:@"http://www.plosone.org/article/feed?category=Rheumatology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Science Policy"
								 URL:@"http://www.plosone.org/article/feed?category=Science%20Policy"
						   imageName:nil],
				 [Feed feedWithTitle:@"Surgery"
								 URL:@"http://www.plosone.org/article/feed?category=Surgery"
						   imageName:nil],
				 [Feed feedWithTitle:@"Urology"
								 URL:@"http://www.plosone.org/article/feed?category=Urology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Virology"
								 URL:@"http://www.plosone.org/article/feed?category=Virology"
						   imageName:nil],
				 [Feed feedWithTitle:@"Women's Health"
								 URL:@"http://www.plosone.org/article/feed?category=Womens%20Health"
						   imageName:nil],
				 nil];
	}
	return self;
}

- (void)dealloc {
	[feeds release];
    [detailViewController release];
    [super dealloc];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return feeds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = @"JournalCell";
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	
	cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] title];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
	cell.textLabel.textColor = (indexPath.row == 0) ? [UIColor blueTextColor] : [UIColor blackColor]; 
	return cell;
}

#pragma mark UITableViewDelegate methods

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 70.0;
//}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Feed *feed = [feeds objectAtIndex:indexPath.row];
	[feed load];
	FeedViewController *viewController = [[[FeedViewController alloc] initWithFeed:feed] autorelease];
	viewController.detailViewController = self.detailViewController;
	[self.navigationController pushViewController:viewController animated:YES];
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

