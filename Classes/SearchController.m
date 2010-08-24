//
//  SearchTableViewDelegate.m
//  Reader
//
//  Created by Tom Brow on 6/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SearchController.h"
#import "ASIHTTPRequest.h"
#import "TouchXML+Extras.h"
#import "Paper+DeepDyve.h"
#import "XMLParsingException.h"
#import "Feed.h"
#import "NSString+Extras.h"
#import "Utilities.h"
#import "Paper+Saving.h"

#define RESULTS_PER_PAGE 25

enum  {kSectionResults, kSectionControls, kNumSections};

@interface SearchController ()

- (void) resetResults;

@end


@implementation SearchController

@synthesize paperCell, searchArchiveCell, detailViewController;

- (NSString *)sanitize:(NSString *)str {
	NSString *spacesPlussed = [str stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	return (NSString*)CFURLCreateStringByAddingPercentEscapes (
															   NULL,
															   (CFStringRef)spacesPlussed,
															   NULL,
															   (CFStringRef)@";/?:@&=$,",
															   kCFStringEncodingUTF8
															   );
}

- (id)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController
{
	if (self = [super initWithSearchBar:searchBar contentsController:viewController]) {
		NSString *responseFile = [(NSString *)CFUUIDCreateString(NULL, CFUUIDCreate(NULL)) autorelease];
		responsePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:responseFile] retain];
		networkQueue = [[ASINetworkQueue alloc] init];
		results = [[NSMutableArray alloc] init];
		
		[self resetResults];
		
		super.delegate = self;
		super.searchResultsDataSource = self;
		super.searchResultsDelegate = self;
		searchBar.delegate = self;
	}
	return self;
}

- (void) dealloc
{	
	[detailViewController release];
	[responsePath release];
	[networkQueue release];
	[results release];
	[savedPapers release];
	[super dealloc];
}

- (void) cleanUpResponseFile {
	NSMutableString *xmlString = [NSMutableString stringWithContentsOfFile:responsePath 
																  encoding:NSUTF8StringEncoding 
																	 error:nil];
	while (true) {
		NSRange range = [xmlString rangeOfString:@"&\\w*=" options:NSRegularExpressionSearch];
		if (range.length > 0) {
			[xmlString replaceCharactersInRange:NSMakeRange(range.location,1)
									 withString:@"%26"];
			[xmlString replaceCharactersInRange:NSMakeRange(range.location+range.length-1,1)
									 withString:@"%3B"];
		}
		else
			break;
	}
	while (true) {
		NSRange range = [xmlString rangeOfString:@"&(ndash|hellip|rarr);" options:NSRegularExpressionSearch];
		if (range.length > 0) {
			[xmlString replaceCharactersInRange:range withString:@""];
		}
		else
			break;
	}
	[xmlString writeToFile:responsePath 
				atomically:NO
				  encoding:NSUTF8StringEncoding 
					 error:nil];
}

- (void)searchOnServer {
	NSString *baseUrl = @"http://plosjournal.deepdyve.com/search?";		
	NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
						   [self sanitize:self.searchBar.text], @"titlewords",
						   [NSNumber numberWithInt:serverResultsPage+1], @"page",
						   [NSNumber numberWithInt:RESULTS_PER_PAGE],@"numPerPage",
						   nil];
	
	NSMutableString *fullUrl = [NSMutableString stringWithString:baseUrl];
	for (NSString *key in query.allKeys)
		[fullUrl appendFormat:@"%@=%@&", key, [query valueForKey:key]];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:fullUrl]];
	request.downloadDestinationPath = responsePath;
	request.delegate = self;
	[networkQueue addOperation:request];
	
	[networkQueue go];
}

- (void) showErrorAlert {
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Search Failed" 
													 message:@"This search could not be completed. Please try again later." 
													delegate:nil 
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil] autorelease];
	[alert show];
}

- (void) resetResults {
	[results removeAllObjects];
	[networkQueue cancelAllOperations];
	didSearchOnServer = NO;
	serverResultsPage = 0;
	didLoadAllResultsPages = NO;
}

- (NSArray *) localResultsForQuery:(NSString *)query {	
	NSMutableSet *localResults = [NSMutableSet set];
	
	for (Feed *feed in [Feed journalFeeds])
		for (Paper *paper in feed.papers)
			if ([paper.title containsString:query])
				[localResults addObject:paper];
	
	for (Paper *paper in savedPapers)
		if ([paper.title containsString:query])
			[localResults addObject:paper];

	return [[localResults allObjects] sortedArrayUsingFunction:dateSort context:nil];
}

#pragma mark UISearchBarDelegate methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	[savedPapers release];
	savedPapers = [[[Paper savedPapersManager] savedPapers] retain];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
	shouldReloadTableForSearchString:(NSString *)searchString {
	[self resetResults];
	[results addObjectsFromArray:[self localResultsForQuery:searchString]];
	return YES;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (didSearchOnServer && didLoadAllResultsPages)
		return kNumSections - 1;
	else
		return kNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case kSectionResults: return results.count;
		case kSectionControls: return 1;
		default: return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kSectionResults) {		
		PaperCell *cell = (PaperCell *)[tableView dequeueReusableCellWithIdentifier:@"PaperCell"];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"PaperCell" 
										  owner:self 
										options:nil];
			cell = self.paperCell;
		}
		
		cell.paper = [results objectAtIndex:indexPath.row];
		return cell;
	} else {
		SearchArchiveCell *cell = (SearchArchiveCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchArchiveCell"];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"SearchArchiveCell" 
										  owner:self 
										options:nil];
			cell = self.searchArchiveCell;
		}
		
		cell.active = [networkQueue isNetworkActive];
		cell.paging = didSearchOnServer;
		return cell;
	}
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.searchBar resignFirstResponder];
	
	if (indexPath.section == kSectionControls) {
		SearchArchiveCell *cell = (SearchArchiveCell *)[self.searchResultsTableView cellForRowAtIndexPath:indexPath];
		if (!cell.active)
			[self searchOnServer];
		[self.searchResultsTableView reloadData];
	} else {
		detailViewController.paper = [results objectAtIndex:indexPath.row];
	}
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSLog(@"[FINISHED]");
	
	[self cleanUpResponseFile];
	NSDictionary *ns = [NSDictionary dictionaryWithObject:@"http://www.w3.org/1999/xhtml" 
												   forKey:@"x"];
	NSError *error = nil;
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:responsePath] 
													options:CXMLDocumentTidyHTML
													  error:&error] autorelease];
	@try {
		NSMutableArray *newResults = [NSMutableArray array];
		for (CXMLNode *node in [doc nodesForXPath:@"//x:ul[@id='resultList']/x:li" namespaceMappings:ns error:&error]) {
			if ([node hasValueForXPath:@"@class" namespaceMappings:ns])
				break;
			[newResults addObject:[[[Paper alloc] initWithDeepDyveHTMLNode:node] autorelease]];
		}
		
		NSSet *resultsSet = [NSSet setWithArray:results];
		for (id result in newResults)
			if (![resultsSet containsObject:result])
				[results addObject:result];
		
		if (newResults.count < RESULTS_PER_PAGE)
			didLoadAllResultsPages = YES;
	}
	@catch (XMLParsingException * e) {
		[self resetResults];
		[self showErrorAlert];
	}
	
	didSearchOnServer = YES;
	serverResultsPage += 1;
	[self.searchResultsTableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{	
	if (request.error.code == ASIRequestCancelledErrorType)
		NSLog(@"[CANCELLED]");
	else {
		NSLog(@"[FAILED]");
		[self.searchResultsTableView reloadData];
	}
}

@end
