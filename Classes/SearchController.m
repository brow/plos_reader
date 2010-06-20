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

enum  {kSectionResults, kSectionControls, kNumSections};

@implementation SearchController

@synthesize paperCell, searchArchiveCell;

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
		didSearchOnServer = NO;
		
		super.delegate = self;
		super.searchResultsDataSource = self;
		super.searchResultsDelegate = self;
		searchBar.delegate = self;
	}
	return self;
}

- (void) dealloc
{	
	[responsePath release];
	[networkQueue release];
	[results release];
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
						   [self sanitize:self.searchBar.text], @"query",
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


#pragma mark UISearchBarDelegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
	shouldReloadTableForSearchString:(NSString *)searchString {
	[results removeAllObjects];
	[networkQueue cancelAllOperations];
	didSearchOnServer = NO;
	return YES;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (didSearchOnServer)
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
		for (CXMLNode *node in [doc nodesForXPath:@"//x:ul[@id='resultList']/x:li" namespaceMappings:ns error:&error]) {
			[results addObject:[[[Paper alloc] initWithDeepDyveHTMLNode:node] autorelease]];
		}
	}
	@catch (XMLParsingException * e) {
		[results removeAllObjects];
		[self showErrorAlert];
	}
	
	didSearchOnServer = YES;
	[self.searchResultsTableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{	
	if (request.error.code == ASIRequestCancelledErrorType)
		NSLog(@"[CANCELLED]");
	else {
		NSLog(@"[FAILED]");
	}

}

@end
