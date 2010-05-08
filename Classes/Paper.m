//
//  Paper.m
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Paper.h"
#import "TouchXML+Extras.h"
#import "NSString+Extras.h"
#import "ASIHTTPRequest.h"
#import "Paper+Saving.h"

@interface Paper()

- (void)setDownloadStatus:(Status)value;
- (void) parsePaperXML:(NSData *)xmlData;

@end

NSString *temporaryPath();

@implementation Paper

@synthesize remotePDFUrl, remoteXMLUrl, title, authors, identifier, localPDFPath, metadata;

- (id) init
{
	if (self = [super init]) {
		xmlDownloaded = NO;
		pdfDownloaded = NO;
		downloadStatus = StatusNotDownloaded;
		metadata = [[NSMutableDictionary alloc] init];
		requests = [[NSMutableArray alloc] init];
		localPDFPath = [temporaryPath() retain];
		localXMLPath = [temporaryPath() retain];
	}
	return self;
}

- (id) initWithPaperXML:(NSData *)xmlData
{
	if (self = [self init]) {
		[self parsePaperXML:xmlData];
	}
	return self;
}

- (void) dealloc
{
	[remotePDFUrl release];
	[remoteXMLUrl release];
	[title release];
	[authors release];
	[identifier release];
	[localPDFPath release];
	[localXMLPath release];
	[metadata release];
	[requests release];
	[super dealloc];
}

- (void) load {	
	if (self.downloadStatus == StatusDownloaded || requests.count > 0)
		return;
	else
		self.downloadStatus = StatusNotDownloaded;

	if ([self saved])
		[self restore];
	
	if (!pdfDownloaded) {
		ASIHTTPRequest *pdfRequest = [ASIHTTPRequest requestWithURL:remotePDFUrl];
		[pdfRequest setDelegate:self];
		[pdfRequest setDownloadDestinationPath:localPDFPath];
		[pdfRequest startAsynchronous];
		NSLog(@"[REQUEST %@]", remotePDFUrl);
		[requests addObject:pdfRequest];
	}
	
	if (!xmlDownloaded) {	
		ASIHTTPRequest *xmlRequest = [ASIHTTPRequest requestWithURL:remoteXMLUrl];
		[xmlRequest setDelegate:self];
		[xmlRequest setDownloadDestinationPath:localXMLPath];
		[xmlRequest startAsynchronous];
		[requests addObject:xmlRequest];
		NSLog(@"[REQUEST %@]", remoteXMLUrl);
	}
}

- (void) cancelLoad {
	for (ASIHTTPRequest *request in [NSArray arrayWithArray:requests])
		[request cancel];
}

- (void) parsePaperXML:(NSData *)xmlData {
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithData:xmlData
												   options:CXMLDocumentTidyXML 
													 error:nil] autorelease];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/title-group/article-title" 
							 namespaceMappings:nil]
				forKey:@"title"];
	
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
}

#pragma mark accessors

- (NSString *) title {
	if (title)
		return title;
	else 
		return [metadata objectForKey:@"title"];
}

- (NSString *) authors {
	if (authors)
		return authors;
	else if ([[metadata objectForKey:@"authors"] count] > 0) {
		NSDictionary *firstAuthor = [[metadata objectForKey:@"authors"] objectAtIndex:0];
		return [NSString stringWithFormat:@"%@ %@%@",
				[firstAuthor objectForKey:@"given-names"],
				[firstAuthor objectForKey:@"surname"],
				([[metadata objectForKey:@"authors"] count] > 1) ? @" et al." : @""];
	}
	else
		 return @"";
}

- (NSString *) doi {
	if (self.identifier)
		return [self.identifier stringByReplacingOccurrencesOfString:@"info:doi/" 
														  withString:@""];
	else
		return [metadata objectForKey:@"doi"];
}

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

- (Status)downloadStatus {
    return downloadStatus;
}

- (void)setDownloadStatus:(Status)value {
    downloadStatus = value;
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{	
	[requests removeObject:request];
	
	if ([request.url isEqual:remoteXMLUrl]) {
		[self parsePaperXML:[NSData dataWithContentsOfFile:localXMLPath]];
		xmlDownloaded = YES;
	} else {
		pdfDownloaded = YES;
	}
	
	if (pdfDownloaded && xmlDownloaded)
		self.downloadStatus = StatusDownloaded;
	
	NSLog(@"[LOADED %@]", request.url);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	[requests removeObject:request];
	
	if (request.error.code == ASIRequestCancelledErrorType)
		NSLog(@"[CANCELLED %@]", request.url);
	else {
		[self cancelLoad];
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Download Failed" 
														 message:@"This paper could not be downloaded. Please check your internet connection and try again." 
														delegate:nil 
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil] autorelease];
		[alert show];
		self.downloadStatus = StatusFailed;
		NSLog(@"[FAILED %@]", request.url);
	}
}

#pragma mark NSObject methods

- (BOOL)isEqual:(id)anObject {
	if (![anObject isKindOfClass:[Paper class]])
		return NO;
	return [self.doi isEqualToString:[anObject doi]];
}

- (NSUInteger)hash {
	return [self.doi hash];
}

@end

NSString *temporaryPath() {
	NSString *uuid = [(NSString *)CFUUIDCreateString(NULL, CFUUIDCreate(NULL)) autorelease];
	return [NSTemporaryDirectory() stringByAppendingPathComponent:uuid];
}
