//
//  Paper.m
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Paper.h"
#import "ASIHTTPRequest.h"
#import "TouchXML+Extras.h"

@implementation Paper

@synthesize remotePDFUrl, remoteXMLUrl, title, authors, localPDFPath, metadata;

- (id) init
{
	if (self = [super init]) {
		xmlDownloaded = NO;
		pdfDownloaded = NO;
		downloaded = NO;
		metadata = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[remotePDFUrl release];
	[remoteXMLUrl release];
	[title release];
	[authors release];
	[localPDFPath release];
	[metadata release];
	[super dealloc];
}

- (void) load {
	if (!localPDFPath) {
		NSString *localFile = (NSString *)CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
		localPDFPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:localFile] retain];
		
		ASIHTTPRequest *pdfRequest = [ASIHTTPRequest requestWithURL:remotePDFUrl];
		[pdfRequest setDelegate:self];
		[pdfRequest setDownloadDestinationPath:localPDFPath];
		[pdfRequest startAsynchronous];
		NSLog(@"[REQUEST %@]", remotePDFUrl);
		
		ASIHTTPRequest *xmlRequest = [ASIHTTPRequest requestWithURL:remoteXMLUrl];
		[xmlRequest setDelegate:self];
		[xmlRequest startAsynchronous];
		NSLog(@"[REQUEST %@]", remoteXMLUrl);
	}
}

- (void) parsePaperXML:(NSData *)xmlData {
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithData:xmlData
												   options:CXMLDocumentTidyXML 
													 error:nil] autorelease];
	[metadata setValue:[doc stringValueForXPath:@"article/front/journal-meta/journal-id[@journal-id-type='nlm-ta']" 
							  namespaceMappings:nil]
				forKey:@"journal-id"];
	[metadata setValue:[doc stringValueForXPath:@"article/front/article-meta/volume" 
							  namespaceMappings:nil]
				forKey:@"volume"];
	[metadata setValue:[doc stringValueForXPath:@"article/front/article-meta/issue" 
							  namespaceMappings:nil]
				forKey:@"issue"];
	[metadata setValue:[doc stringValueForXPath:@"article/front/article-meta/elocation-id" 
							  namespaceMappings:nil]
				forKey:@"elocation-id"];
}

#pragma mark accessors

- (NSString *) volumeIssueId {
	return [NSString stringWithFormat:@"%@ %@(%@): %@",
			[metadata objectForKey:@"journal-id"],
			[metadata objectForKey:@"volume"],
			[metadata objectForKey:@"issue"],
			[metadata objectForKey:@"elocation-id"],
			nil];
}

- (BOOL)downloaded {
    return downloaded;
}

- (void)setDownloaded:(BOOL)aDownloaded {
	downloaded = aDownloaded;
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{	
	if ([request.url isEqual:remoteXMLUrl]) {
		[self parsePaperXML:request.responseData];
		xmlDownloaded = YES;
	} else {
		pdfDownloaded = YES;
	}
	
	if (pdfDownloaded && xmlDownloaded)
		self.downloaded = YES;
	
	NSLog(@"[LOADED %@]", request.url);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSLog(@"[FAILED %@]", request.url);
}

@end
