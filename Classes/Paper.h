//
//  Paper.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

typedef enum {StatusNotDownloaded, StatusDownloaded, StatusFailed} Status;

@interface Paper : NSObject {
	NSURL *remotePDFUrl, *remoteXMLUrl;
	NSString *localPDFPath, *localXMLPath;
	NSString *title, *authors, *identifier;
	NSMutableDictionary *metadata;
	ASINetworkQueue *requestsQueue;
	
	Status downloadStatus;
	float downloadProgress;
}

@property (retain) NSURL *remotePDFUrl;
@property (retain) NSURL *remoteXMLUrl;
@property (readonly) NSDate *date;
@property (readonly) NSString *title;
@property (readonly) NSString *authors;
@property (readonly) NSString *localPDFPath;
@property (readonly) Status downloadStatus;
@property (readonly) float downloadProgress;
@property (readonly) NSDictionary *metadata;
@property (readonly) NSString *volumeIssueId;
@property (readonly) NSString *citation;
@property (readonly) NSString *runningHead;
@property (readonly) NSString *doi;
@property (readonly) NSString *doiLink;
@property (readonly) NSString *shortJournalTitle;
@property (retain) NSString *feedTitle;

+ (id) paperWithAtomXMLNode:(id)xmlString;
- (id) initWithAtomXMLNode:(id)xmlString;
- (id) initWithPaperXML:(NSData *)xmlData;
- (void) parsePaperXML:(NSData *)xmlData;
- (void) load;
- (void) cancelLoad;

@end
