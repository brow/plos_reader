//
//  SpecialHTTPRequest.m
//  Reader
//
//  Created by Tom Brow on 5/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SpecialHTTPRequest.h"


@implementation SpecialHTTPRequest

#pragma mark ASIHTTPRequest methods

- (ASIHTTPRequest *)HEADRequest
{
	
	ASIHTTPRequest *headRequest = [super HEADRequest];
	headRequest.timeOutSeconds = self.timeOutSeconds;
	return headRequest;
}

@end
