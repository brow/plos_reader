//
//  Paper.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {StatusNotDownloaded, StatusDownloaded, StatusFailed} Status;

@interface Paper : NSObject {
	NSURL *remotePDFUrl, *remoteXMLUrl;
	NSString *localPDFPath, *localXMLPath;
	NSString *title, *authors, *identifier;
	NSMutableDictionary *metadata;
	NSMutableArray *requests;
	
	BOOL pdfDownloaded, xmlDownloaded;
	Status downloadStatus;
}

@property (retain) NSURL *remotePDFUrl;
@property (retain) NSURL *remoteXMLUrl;
@property (retain) NSString *title;
@property (retain) NSString *authors;
@property (retain) NSString *identifier;
@property (readonly) NSString *localPDFPath;
@property (readonly) Status downloadStatus;
@property (readonly) NSDictionary *metadata;
@property (readonly) NSString *volumeIssueId;
@property (readonly) NSString *citation;
@property (readonly) NSString *runningHead;
@property (readonly) NSString *doi;

- (id) initWithPaperXML:(NSData *)xmlData;
- (void) parsePaperXML:(NSData *)xmlData;
- (void) load;
- (void) cancelLoad;

@end
