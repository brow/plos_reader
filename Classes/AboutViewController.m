    //
//  AboutViewController.m
//  Reader
//
//  Created by Tom Brow on 5/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize aboutJournalLabel, aboutPLoSView, journalLogoView;

- (id)initWithFeed:(Feed *)aFeed {
    if ((self = [super initWithNibName:@"AboutViewController" bundle:nil])) {
		feed = [aFeed retain];
		journalInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
					   @"The first PLoS Journal, featuring works of exceptional significance, originality, and relevance in all areas of biological science, from molecules to ecosystems, including works at the interface of other disciplines, such as chemistry, medicine, and mathematics. The audience for PLoS Biology is the international scientific community as well as educators, policymakers, and interested members of the public around the world.",
					   [NSURL URLWithString:@"http://www.plosbiology.org/article/feed"],
					   @"PLoS Medicine provides an innovative and influential venue for research and comment on the major challenges to human health worldwide. The journal publishes papers which have relevance across a range of settings and that address the major environmental, social, and political determinants of health, as well as the biological. The journal gives the highest priority to papers on the conditions and risk factors that cause the highest mortality and burden of disease worldwide.",
					   [NSURL URLWithString:@"http://www.plosmedicine.org/article/feed"],
					   @"PLoS Computational Biology makes connections between disparate areas of biology by featuring works that provide substantial new insight into living systems at all scales— including molecular science, neuroscience, physiology, and population biology—through the application of computational methods.",
					   [NSURL URLWithString:@"http://www.ploscompbiol.org/article/feed"],
					   @"PLoS Genetics reflects the full breadth and interdisciplinary nature of genetics and genomics research by publishing outstanding original contributions in all areas of biology, from mice and flies, to plants and bacteria.",
					   [NSURL URLWithString:@"http://www.plosgenetics.org/article/feed"],
					   @"From molecules to physiology, PLoS Pathogens publishes important new ideas on bacteria, fungi, parasites, prions, and viruses that contribute to our understanding of the biology of pathogens and pathogen–host interactions.",
					   [NSURL URLWithString:@"http://www.plospathogens.org/article/feed"],
					   @"The first open-access journal devoted to neglected tropical diseases, PLoS Neglected Tropical Diseases publishes high-quality, peer-reviewed research on all scientific, medical, and public health aspects of these forgotten diseases affecting the world's forgotten people.",
					   [NSURL URLWithString:@"http://www.plosntds.org/article/feed"],
					   @"Fast, efficient, and economical, publishing peer-reviewed research in all areas of science and medicine. The peer review process does not judge the importance of the work, rather focuses on whether the work is done to high scientific and ethical standards, is appropriately described, and that the data support the conclusions. Combining tools for commentary and rating, PLoS ONE is also a unique forum for community discussion and assessment of articles.",
					   @"",
					   nil];
		journalLogos = [[NSDictionary alloc] initWithObjectsAndKeys:
						@"About_Biology.png",
						[NSURL URLWithString:@"http://www.plosbiology.org/article/feed"],
						@"About_Medicine.png",
						[NSURL URLWithString:@"http://www.plosmedicine.org/article/feed"],
						@"About_CompBio.png",
						[NSURL URLWithString:@"http://www.ploscompbiol.org/article/feed"],
						@"About_Genetics.png",
						[NSURL URLWithString:@"http://www.plosgenetics.org/article/feed"],
						@"About_Pathogens.png",
						[NSURL URLWithString:@"http://www.plospathogens.org/article/feed"],
						@"About_NTD.png",
						[NSURL URLWithString:@"http://www.plosntds.org/article/feed"],
						@"About_One.png",
						@"",
						nil];
    }
    return self;
}

- (void)dealloc {
	[aboutJournalLabel release];
	[aboutPLoSView release];
	[journalLogoView release];
	
	[feed release];
	[journalInfo release];
	[journalLogos release];
    [super dealloc];
}

#pragma mark actions

- (IBAction) dismiss:(id)sender {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *aboutJournalText = [journalInfo objectForKey:feed.url];
	if (aboutJournalText)
		aboutJournalLabel.text = aboutJournalText;
	else
		aboutJournalLabel.text = [journalInfo objectForKey:@""];
	
	CGSize aboutJournalSize = [aboutJournalLabel.text sizeWithFont:aboutJournalLabel.font 
											constrainedToSize:CGSizeMake(aboutJournalLabel.frame.size.width, HUGE_VALF)
												lineBreakMode:aboutJournalLabel.lineBreakMode];
	aboutJournalLabel.frame = CGRectMake(aboutJournalLabel.frame.origin.x,
									aboutJournalLabel.frame.origin.y,
									aboutJournalLabel.frame.size.width, 
									aboutJournalSize.height);
	
	aboutPLoSView.frame = CGRectMake(aboutPLoSView.frame.origin.x,
									 aboutJournalLabel.frame.origin.y + aboutJournalLabel.frame.size.height,
									 aboutPLoSView.frame.size.width,
									 aboutPLoSView.frame.size.height);
	
	NSString *logoName = [journalLogos objectForKey:feed.url];
	if (logoName)
		journalLogoView.image = [UIImage imageNamed:logoName];
	else 
		journalLogoView.image = [UIImage imageNamed:[journalLogos objectForKey:@""]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


@end
