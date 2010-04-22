//
//  Feed.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Feed : NSObject {
	NSURL *url;
	NSMutableArray *papers;
}

@property (readonly) NSArray *papers;

- (void) load;

@end
