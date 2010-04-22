//
//  Feed.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Feed : NSObject {
	NSString *title;
	NSURL *url;
	NSMutableArray *papers;
}

@property (readonly) NSString *title;
@property (readonly) NSArray *papers;

+ (id) feedWithTitle:(NSString *)title URL:(NSString *)urlString;
- (id) initWithTitle:(NSString *)aTitle URL:(NSString *)urlString;
- (void) load;

@end
