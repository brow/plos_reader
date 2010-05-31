//
//  LeavesCache.h
//  Reader
//
//  Created by Tom Brow on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LeavesTrivialCache.h"

@interface LeavesCache : LeavesTrivialCache {
	NSMutableDictionary *pageCache;
}

@end
