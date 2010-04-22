//
//  Feed.m
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"
#import "ASIHTTPRequest.h"
#import "TouchXML+Extras.h"
#import "Paper.h"

@implementation Feed

@synthesize papers;

- (id) init
{
	if (self = [super init]) {
		url = [[NSURL alloc] initWithString:@"http://www.plosntds.org/article/feed"];
		papers = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[url release];
	[papers release];
	[super dealloc];
}

- (void) load {
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request startAsynchronous];
}

#pragma mark kvc accessors

- (NSArray *)papers {
    return papers;
}

- (unsigned)countOfPapers {
    return papers.count;
}

- (id)objectInPapersAtIndex:(unsigned)theIndex {
    return [papers objectAtIndex:theIndex];
}

- (void)getPapers:(id *)objsPtr range:(NSRange)range {
    [papers getObjects:objsPtr range:range];
}

- (void)insertObject:(id)obj inPapersAtIndex:(unsigned)theIndex {
    [papers insertObject:obj atIndex:theIndex];
}

- (void)removeObjectFromPapersAtIndex:(unsigned)theIndex {
    [papers removeObjectAtIndex:theIndex];
}

- (void)replaceObjectInPapersAtIndex:(unsigned)theIndex withObject:(id)obj {
    [papers replaceObjectAtIndex:theIndex withObject:obj];
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithData:[request responseData] 
													  options:CXMLDocumentTidyXML 
														error:nil] autorelease];
	
	NSDictionary *ns = [NSDictionary dictionaryWithObject:@"http://www.w3.org/2005/Atom" 
														   forKey:@"a"];
	
	NSMutableArray *newPapers = [NSMutableArray array];
	for (CXMLNode *paperNode in [doc nodesForXPath:@"a:feed/a:entry" namespaceMappings:ns error:nil]) {
		Paper *paper = [[[Paper alloc] init] autorelease];
		if ([paperNode hasValueForXPath:@"./a:author/a:name" namespaceMappings:ns]) {
			paper.title = [paperNode stringValueForXPath:@"./a:title" namespaceMappings:ns];
			paper.authors = [paperNode stringValueForXPath:@"./a:author/a:name" namespaceMappings:ns];
			NSString *pdfUrl = [paperNode stringValueForXPath:@"./a:link[@type='application/pdf']/@href" namespaceMappings:ns];
			paper.pdfUrl = [NSURL URLWithString:pdfUrl];
			
			[newPapers addObject:paper];
		}
	}
	
	[[self mutableArrayValueForKey:@"papers"] addObjectsFromArray:newPapers];
	
	NSLog(@"[LOADED %@]", url);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
//	NSError *error = [request error];
	NSLog(@"[FAILED %@]", url);
}


@end
