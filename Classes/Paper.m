//
//  Paper.m
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Paper.h"
#import "ASIHTTPRequest.h"

@implementation Paper

@synthesize remoteUrl, title, authors, localPath;

- (id) init
{
	if (self = [super init]) {
		downloaded = NO;
	}
	return self;
}


- (void) load {
	if (!localPath) {
		NSString *localFile = (NSString *)CFUUIDCreateString(NULL, CFUUIDCreate(NULL));
		localPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:localFile] retain];
		
		ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:remoteUrl];
		[request setDelegate:self];
		[request setDownloadDestinationPath:localPath];
		[request startAsynchronous];
		NSLog(@"[REQUEST %@]", remoteUrl);
	}
}

- (void) dealloc
{
	[remoteUrl release];
	[title release];
	[authors release];
	[localPath release];
	[super dealloc];
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

#pragma mark ASIHTTPRequest delegate methods

- (void)requestFinished:(ASIHTTPRequest *)request
{	
	NSLog(@"[LOADED %@]", remoteUrl);
	self.downloaded = YES;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSLog(@"[FAILED %@]", remoteUrl);
}


@end
