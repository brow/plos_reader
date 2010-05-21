//
//  SpecialHTTPRequest.m
//  Reader
//
//  Created by Tom Brow on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SpecialHTTPRequest.h"


@implementation SpecialHTTPRequest

- (id)initWithURL:(NSURL *)newURL
{
	if (self = [super initWithURL:newURL]) {
		defaultContentLength = 0;
	}
	return self;
}

- (unsigned long long) contentLength {
	if (super.contentLength)
		return super.contentLength;
	else
		return defaultContentLength;
}

- (void) setContentLength:(unsigned long long)value {
	[(id)super setContentLength:value];
	if (value)
		defaultContentLength = value;
}

@end
