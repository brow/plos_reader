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

@synthesize papers, title, url;

+ (id) feedWithTitle:(NSString *)title URL:(NSString *)urlString imageName:(NSString *)aImageName {
	return [[[[self class] alloc] initWithTitle:title URL:urlString imageName:aImageName] autorelease];
}

- (id) initWithTitle:(NSString *)aTitle URL:(NSString *)urlString imageName:(NSString *)aImageName;
{
	if (self = [super init]) {
		title = [aTitle retain];
		url = [[NSURL alloc] initWithString:urlString];
		papers = [[NSMutableArray alloc] init];
		imageName = [aImageName retain];
		downloaded = NO;
		requestsQueue = [[ASINetworkQueue alloc] init];
		
		NSString *localFile = [(NSString *)CFUUIDCreateString(NULL, CFUUIDCreate(NULL)) autorelease];
		localXMLPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:localFile] retain];
	}
	return self;
}

- (void) dealloc
{
	[localXMLPath release];
	[title release];
	[url release];
	[papers release];
	[imageName release];
	[requestsQueue release];
	[super dealloc];
}

- (void) load {
	if (requestsQueue.isNetworkActive)
		return;
	
	[requestsQueue reset];
	requestsQueue.delegate = self;
	requestsQueue.requestDidFinishSelector = @selector(requestFinished:);
	requestsQueue.requestDidFailSelector = @selector(requestFailed:);
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDownloadDestinationPath:localXMLPath];
	[requestsQueue addOperation:request];
	[self setValue:[NSNumber numberWithBool:NO] forKey:@"downloaded"];
	NSLog(@"[REQUEST %@]", url);
	
	[requestsQueue go];
}

- (void) parseFeedXML:(NSData *)data {
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithData:data 
													options:CXMLDocumentTidyXML 
													  error:nil] autorelease];
	
	NSDictionary *ns = [NSDictionary dictionaryWithObject:@"http://www.w3.org/2005/Atom" 
												   forKey:@"a"];
	
	NSMutableArray *newPapers = [NSMutableArray array];
	for (CXMLNode *paperNode in [doc nodesForXPath:@"a:feed/a:entry" namespaceMappings:ns error:nil])
		if ([paperNode hasValueForXPath:@"./a:author/a:name" namespaceMappings:ns]) {
			Paper *paper = [Paper paperWithAtomXMLNode:paperNode];
			paper.feedTitle = self.title;
			[newPapers addObject:paper];
		}
	
	[[self mutableArrayValueForKey:@"papers"] addObjectsFromArray:newPapers];
}

#pragma mark accessors

- (BOOL)downloaded {
    return downloaded;
}

- (void)setDownloaded:(BOOL)value {
    if (downloaded != value) {
        downloaded = value;
    }
}

- (UIImage *) image {
	return [UIImage imageNamed:imageName];
}

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
	self.downloaded = YES;
	[self parseFeedXML:[NSData dataWithContentsOfFile:localXMLPath]];
	NSLog(@"[LOADED %@]", url);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	self.downloaded = YES;
	NSLog(@"[FAILED %@]", url);
}


@end
