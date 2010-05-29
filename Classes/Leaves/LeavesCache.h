//
//  LeavesCache.h
//  Reader
//
//  Created by Tom Brow on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LeavesView.h"

@interface LeavesCache : NSObject <LeavesViewCache> {
	NSMutableDictionary *pageCache;
	CGSize pageSize;
}

- (id) initWithPageSize:(CGSize)aPageSize;

@end
