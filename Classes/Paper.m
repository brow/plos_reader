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
#import "NSString+Extras.h"

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
		NSString *localFile = [(NSString *)CFUUIDCreateString(NULL, CFUUIDCreate(NULL)) autorelease];
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
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/journal-meta/journal-id[@journal-id-type='nlm-ta']" 
							  namespaceMappings:nil]
				forKey:@"journal-id"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/volume" 
							  namespaceMappings:nil]
				forKey:@"volume"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/issue" 
							  namespaceMappings:nil]
				forKey:@"issue"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/elocation-id" 
							  namespaceMappings:nil]
				forKey:@"elocation-id"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/article-id[@pub-id-type='doi']" 
							  namespaceMappings:nil]
				forKey:@"doi"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/pub-date[@pub-type='epub']/year" 
							  namespaceMappings:nil]
				forKey:@"year"];
	
	NSString *runningHeadPath = @"article/front/article-meta/title-group/alt-title[@alt-title-type='running-head']";
	if ([doc hasValueForXPath:runningHeadPath namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:runningHeadPath namespaceMappings:nil]
					forKey:@"running-head"];
	
	NSMutableArray *authorsMetadata = [NSMutableArray array];
	for (CXMLNode *authorNode in [doc nodesForXPath:
			@"article/front/article-meta/contrib-group/contrib[@contrib-type='author']/name[@name-style='western']" error:nil]) {
		[authorsMetadata addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									[authorNode flatStringForXPath:@"./surname" namespaceMappings:nil], @"surname",
									[authorNode flatStringForXPath:@"./given-names" namespaceMappings:nil], @"given-names",
									nil]];
	}
	[metadata setValue:authorsMetadata forKey:@"authors"];
	 
	NSLog(@"%@", metadata);
}

#pragma mark accessors

- (NSString *) runningHead {
	NSString *runningHead = [metadata objectForKey:@"running-head"];
	if (runningHead)
		return runningHead;
	else
		return self.title;
}

- (NSString *) volumeIssueId {
	return [NSString stringWithFormat:@"%@ %@(%@): %@",
			[metadata objectForKey:@"journal-id"],
			[metadata objectForKey:@"volume"],
			[metadata objectForKey:@"issue"],
			[metadata objectForKey:@"elocation-id"],
			nil];
}

- (NSString *) citation {
	NSMutableString *citationString = [NSMutableString string];
	
	NSArray *authorsArr = [metadata objectForKey:@"authors"];
	for (NSDictionary *author in authorsArr)
		if ([authorsArr indexOfObject:author] < 5)
			[citationString appendFormat:@"%@ %@%@", 
			 [author objectForKey:@"surname"], 
			 [[author objectForKey:@"given-names"] initials],
			 ([authorsArr indexOfObject:author] < authorsArr.count-1) ? @", " : @" "];
	
	if (authorsArr.count > 5)
		[citationString appendString:@"et al. "];
	
	[citationString appendFormat:@"(%@) %@. %@. doi:%@",
	 [metadata objectForKey:@"year"],
	 self.title,
	 self.volumeIssueId,
	 [metadata objectForKey:@"doi"]
	 ];
	
	return citationString;
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
