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
#import "SpecialHTTPRequest.h"
#import "Paper+Saving.h"


@interface Paper() <ASIProgressDelegate>

- (void)setDownloadStatus:(Status)value;
- (void) parsePaperXML:(NSData *)xmlData;
- (void) parseAtomXMLNode:(id)node;

@end

NSString *temporaryPath();

@implementation Paper

@synthesize remotePDFUrl, remoteXMLUrl, localPDFPath, metadata;

+ (id) paperWithAtomXMLNode:(id)node {
	return [[[Paper alloc] initWithAtomXMLNode:node] autorelease];
}

- (id) init
{
	if (self = [super init]) {
		downloadProgress = 0;
		downloadStatus = StatusNotDownloaded;
		metadata = [[NSMutableDictionary alloc] init];
		requestsQueue = [[ASINetworkQueue alloc] init];
		localPDFPath = [temporaryPath() retain];
		localXMLPath = [temporaryPath() retain];
		errors = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id) initWithAtomXMLNode:(id)node {
	if (self = [self init]) {
		[self parseAtomXMLNode:node];
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
	[requestsQueue release];
	[errors release];
	[super dealloc];
}

- (void) load {
	/* Do nothing if this paper is already downloading or downloaded.*/
	if (self.downloadStatus == StatusDownloaded || requestsQueue.isNetworkActive)
		return;
	else
		self.downloadStatus = StatusNotDownloaded;

	/* Simply restore the paper if it has been saved permanently. */
	if ([self saved]) {
		[self restore];
		return;
	}
	
	[errors removeAllObjects];
	[requestsQueue reset];
	requestsQueue.delegate = self;
	requestsQueue.downloadProgressDelegate = self;
	requestsQueue.showAccurateProgress = YES;
	requestsQueue.requestDidFinishSelector = @selector(requestFinished:);
	requestsQueue.requestDidFailSelector = @selector(requestFailed:);
	requestsQueue.queueDidFinishSelector = @selector(queueDidFinish:);
	
	ASIHTTPRequest *pdfRequest = [SpecialHTTPRequest requestWithURL:remotePDFUrl];
	pdfRequest.downloadDestinationPath = localPDFPath;	
	[pdfRequest setTimeOutSeconds:15];
	[requestsQueue addOperation:pdfRequest];
	NSLog(@"[REQUEST %@]", remotePDFUrl);

	ASIHTTPRequest *xmlRequest = [SpecialHTTPRequest requestWithURL:remoteXMLUrl];
	xmlRequest.downloadDestinationPath = localXMLPath;
	[xmlRequest setTimeOutSeconds:15];
	[requestsQueue addOperation:xmlRequest];
	NSLog(@"[REQUEST %@]", remoteXMLUrl);
	
	[requestsQueue go];
}

- (void) cancelLoad {
	[requestsQueue cancelAllOperations];
}

- (void) parseAtomXMLNode:(id)node {
	NSDictionary *ns = [NSDictionary dictionaryWithObject:@"http://www.w3.org/2005/Atom" 
												   forKey:@"a"];	
	[metadata setValue:[node flatStringForXPath:@"./a:title" namespaceMappings:ns]
				forKey:@"title"];
	
	[metadata setValue:[node flatStringForXPath:@"./a:author/a:name" namespaceMappings:ns] 
				forKey:@"authors-short"];
	
	[metadata setValue:[[node flatStringForXPath:@"./a:id" namespaceMappings:ns] 
						stringByReplacingOccurrencesOfString:@"info:doi/" withString:@""] 
				forKey:@"doi"];
	
	[metadata setValue:[node flatStringForXPath:@"./a:published" namespaceMappings:ns]  
				forKey:@"published"];
		
	NSString *pdfUrl = [node flatStringForXPath:@"./a:link[@type='application/pdf']/@href" namespaceMappings:ns];
	self.remotePDFUrl = [NSURL URLWithString:pdfUrl];
	
	NSString *xmlUrl = [node flatStringForXPath:@"./a:link[@type='text/xml']/@href" namespaceMappings:ns];
	self.remoteXMLUrl = [NSURL URLWithString:xmlUrl];
	
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
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/journal-meta/journal-title" 
							 namespaceMappings:nil] 
				forKey:@"journal-title"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/volume" 
							  namespaceMappings:nil]
				forKey:@"volume"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/issue" 
							  namespaceMappings:nil]
				forKey:@"issue"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/issue" 
							 namespaceMappings:nil]
				forKey:@"issue"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/pub-date[@pub-type='epub']/day" 
							 namespaceMappings:nil]
				forKey:@"pub-day"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/pub-date[@pub-type='epub']/month" 
							 namespaceMappings:nil]
				forKey:@"pub-month"];
	
	[metadata setValue:[doc flatStringForXPath:@"article/front/article-meta/pub-date[@pub-type='epub']/year" 
							 namespaceMappings:nil]
				forKey:@"pub-year"];
	
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

+ (NSString *)shortenedTitleForJournalTitle:(NSString*)journalTitle {
	NSDictionary *shortenedTitles = [NSDictionary dictionaryWithObjectsAndKeys:
									 @"PLoS Comp Bio", @"PLoS Computational Biology",
									 @"PLoS NTD", @"PLoS Neglected Tropical Diseases",
									 nil];
	if ([shortenedTitles objectForKey:journalTitle])
		return [shortenedTitles objectForKey:journalTitle];
	else
		return journalTitle;
}

#pragma mark accessors

- (NSString *) feedTitle {
	return [metadata objectForKey:@"feed-title"];
}

- (void) setFeedTitle:(NSString *)value {
	[metadata setObject:value 
				 forKey:@"feed-title"];
}

- (NSString *) shortJournalTitle {
	if ([metadata objectForKey:@"journal-title"])
		return [[self class] shortenedTitleForJournalTitle:[metadata objectForKey:@"journal-title"]];
	else
		return self.feedTitle;
}

- (NSDate *) date {
	if ([metadata objectForKey:@"published"]) {
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
		dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
		return [dateFormatter dateFromString:[metadata objectForKey:@"published"]];
	}
	else if ([metadata objectForKey:@"pub-day"] && 
			 [metadata objectForKey:@"pub-month"] &&
			 [metadata objectForKey:@"pub-year"]) {
		NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
		components.year = [[metadata objectForKey:@"pub-year"] intValue];
		components.month = [[metadata objectForKey:@"pub-month"] intValue];
		components.day = [[metadata objectForKey:@"pub-day"] intValue];
		components.hour = 7;
		NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
		calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
		return [calendar dateFromComponents:components];
	}
		return nil;
}

- (NSString *) title {
	return [metadata objectForKey:@"title"];
}

- (NSString *) authors {
	if ([metadata objectForKey:@"authors-short"])
		return [metadata objectForKey:@"authors-short"];
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
	return [metadata objectForKey:@"doi"];
}

- (NSString *) doiLink {
	if (self.doi)
		return [NSString stringWithFormat:@"http://dx.doi.org/%@", self.doi];
	else
		return nil;
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

- (float)downloadProgress {
    return downloadProgress;
}

- (void)setDownloadProgress:(float)value {
    if (downloadProgress != value) {
        downloadProgress = value;
    }
}

#pragma mark ASIProgressDelegate methods

- (void)setProgress:(float)newProgress {
	NSLog(@"%.2f", newProgress);
	[self setDownloadProgress:newProgress];
}

#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{		
	NSLog(@"[LOADED %@]", request.url);
}

- (void)requestFailed:(ASIHTTPRequest *)request
{		
	[errors addObject:request.error];
	if (request.error.code == ASIRequestCancelledErrorType)
		NSLog(@"[CANCELLED %@]", request.url);
	else {
		self.downloadStatus = StatusFailed;
		NSLog(@"[FAILED %@]", request.url);
		if (errors.count == 1) {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Download Failed" 
															 message:@"This paper could not be downloaded. Please check your internet connection and try again." 
															delegate:nil 
												   cancelButtonTitle:@"OK" 
												   otherButtonTitles:nil] autorelease];
			[alert show];
		}
	}
}

- (void) queueDidFinish:(ASINetworkQueue *)queue {
	if (errors.count > 0)
		self.downloadStatus = StatusFailed;
	else {
		[self parsePaperXML:[NSData dataWithContentsOfFile:localXMLPath]];
		self.downloadStatus = StatusDownloaded;
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
