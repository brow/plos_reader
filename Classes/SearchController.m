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

@implementation SearchController

@synthesize paperCell;

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
		responsePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"search_response.xml"] retain];
		results = [[NSMutableArray alloc] init];
		
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

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return results.count;
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
	
	cell.paper = [results objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100.0;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark UISearchBarDelegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
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
	[request startAsynchronous];
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
	[self cleanUpResponseFile];
	NSDictionary *ns = [NSDictionary dictionaryWithObject:@"http://www.w3.org/1999/xhtml" 
												   forKey:@"x"];
	NSError *error = nil;
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:responsePath] 
													options:CXMLDocumentTidyHTML
													  error:&error] autorelease];
	
	
	
	for (CXMLNode *node in [doc nodesForXPath:@"//x:ul[@id='resultList']/x:li" namespaceMappings:ns error:&error]) {
		[[[Paper alloc] initWithDeepDyveHTMLNode:node] autorelease];
	}
	
}

- (void)requestFailed:(ASIHTTPRequest *)request
{		
	NSLog(@"[FAILED]");
}

@end
