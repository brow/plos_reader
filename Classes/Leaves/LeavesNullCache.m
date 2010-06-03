//
//  LeavesNullCache.m
//  Reader
//
//  Created by Tom Brow on 6/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LeavesNullCache.h"


@implementation LeavesNullCache

@synthesize pageSize;

- (id) init
{
	if ([super init]) {
		pageSize = CGSizeZero;
	}
	return self;
}

#pragma mark LeavesViewCache methods

- (CGImageRef) imageForPageAtIndex:(NSUInteger)pageIndex fromDataSource:(id<LeavesViewDataSource>)dataSource {
	return NULL;
}

- (void) flush {
}

@end
