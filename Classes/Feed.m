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
#import "XMLParsingException.h"

@interface Feed ()
- (NSString *) feedPath;
- (void) parseFeedXML:(NSData *)data;
@end

static NSArray *journalFeeds;

@implementation Feed

@synthesize papers, title, url;

+ (NSArray *) journalFeeds {
	if (!journalFeeds) {
		journalFeeds = [[NSArray alloc] initWithObjects:
						 [Feed feedWithTitle:@"PLoS Biology" 
										 URL:@"http://www.plosbiology.org/article/feed" 
								   imageName:@"PLoS_Biology.png"], 
						 [Feed feedWithTitle:@"PLoS Medicine" 
										 URL:@"http://www.plosmedicine.org/article/feed" 
								   imageName:@"PLoS_Medicine.png"], 
						 [Feed feedWithTitle:@"PLoS Genetics" 
										 URL:@"http://www.plosgenetics.org/article/feed" 
								   imageName:@"PLoS_Genetics.png"], 
						 [Feed feedWithTitle:@"PLoS Pathogens" 
										 URL:@"http://www.plospathogens.org/article/feed" 
								   imageName:@"PLoS_Pathogens.png"],
						 [Feed feedWithTitle:@"PLoS Comp Bio" 
										 URL:@"http://www.ploscompbiol.org/article/feed" 
								   imageName:@"PLoS_CompBio.png"], 
						 [Feed feedWithTitle:@"PLoS NTD" 
										 URL:@"http://www.plosntds.org/article/feed" 
								   imageName:@"PLoS_NTD.png"],
						 [Feed feedWithTitle:@"PLoS ONE" 
										 URL:@"http://feeds.plos.org/plosone/PLoSONE" 
								   imageName:@"PLoS_One.png"],
						 nil];
	}
	return journalFeeds;
}

+ (id) feedWithTitle:(NSString *)title URL:(NSString *)urlString imageName:(NSString *)aImageName {
	return [[[[self class] alloc] initWithTitle:title URL:urlString imageName:aImageName] autorelease];
}

+ (NSString *) documentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *) feedsDirectory {
	return [[self documentsDirectory] stringByAppendingPathComponent:@"feeds"];
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
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:[self feedPath]]) {
			@try {
				[self parseFeedXML:[NSData dataWithContentsOfFile:[self feedPath]]];
			}
			@catch (XMLParsingException *e) {
			}
		}
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

- (NSString *) feedPath {
	NSCharacterSet *unsafeChars = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	NSString *filename = [[self.url.absoluteString componentsSeparatedByCharactersInSet:unsafeChars] 
						  componentsJoinedByString:@"_"];
	return [[self.class feedsDirectory] stringByAppendingPathComponent:filename];
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
//	NSLog(@"[REQUEST %@]", url);
	
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
{	@try {
		[self parseFeedXML:[NSData dataWithContentsOfFile:localXMLPath]];
	
		/* Save XML to non-temporary file. */
		if (![[NSFileManager defaultManager] fileExistsAtPath:[self.class feedsDirectory]])
			[[NSFileManager defaultManager] createDirectoryAtPath:[self.class feedsDirectory]
													   attributes:nil];
		if ([[NSFileManager defaultManager] fileExistsAtPath:self.feedPath])
			[[NSFileManager defaultManager] removeItemAtPath:self.feedPath error:nil];
		[[NSFileManager defaultManager] copyItemAtPath:localXMLPath 
												toPath:self.feedPath
												 error:nil];
	}
	@catch (XMLParsingException *e) {
	}
	self.downloaded = YES;
		
//	NSLog(@"[LOADED %@]", url);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	self.downloaded = YES;
//	NSLog(@"[FAILED %@]", url);
}


@end
