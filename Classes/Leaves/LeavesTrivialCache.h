//
//  LeavesTrivialCache.h
//  Reader
//
//  Created by Tom Brow on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LeavesView.h"


@interface LeavesTrivialCache : NSObject <LeavesViewCache> {
	CGSize pageSize;
}

- (CGImageRef) freshImageForPageIndex:(NSUInteger)pageIndex fromDataSource:(id<LeavesViewDataSource>)dataSource;

@end
