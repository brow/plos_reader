//
//  Paper.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Paper : NSObject {
	NSURL *remotePDFUrl, *remoteXMLUrl;
	NSString *localPDFPath;
	NSString *title, *authors;
	NSMutableDictionary *metadata;
	
	BOOL pdfDownloaded, xmlDownloaded, downloaded;
}

@property (retain) NSURL *remotePDFUrl;
@property (retain) NSURL *remoteXMLUrl;
@property (retain) NSString *title;
@property (retain) NSString *authors;
@property (readonly) NSString *localPDFPath;
@property (readonly) BOOL downloaded;
@property (readonly) NSDictionary *metadata;
@property (readonly) NSString *volumeIssueId;

- (void) load;

@end
