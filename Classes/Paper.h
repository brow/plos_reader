//
//  Paper.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Paper : NSObject {
	NSURL *remoteUrl;
	NSString *localPath;
	NSString *title, *authors;
	
	BOOL downloaded;
}

@property (retain) NSURL *remoteUrl;
@property (retain) NSString *title;
@property (retain) NSString *authors;
@property (readonly) NSString *localPath;
@property (readonly) BOOL downloaded;

- (void) load;

@end
