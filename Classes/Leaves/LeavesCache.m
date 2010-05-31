//
//  LeavesCache.m
//  Reader
//
//  Created by Tom Brow on 5/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LeavesCache.h"
#import "LeavesView.h"

@implementation LeavesCache

- (id) init
{
	if ([super init]) {
		pageCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[pageCache release];
	[super dealloc];
}

- (void) precacheImageFor:(NSDictionary *)info {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self imageForPageAtIndex:[[info objectForKey:@"pageIndex"] intValue]
			   fromDataSource:[info objectForKey:@"dataSource"]
	 ];
	[pool release];
}

#pragma mark accessors

- (void) setPageSize:(CGSize)value {
	if (!CGSizeEqualToSize(pageSize, value)) {
		pageSize = value;
		[self flush];
	}
}

#pragma mark LeavesViewCache methods

- (CGImageRef) imageForPageAtIndex:(NSUInteger)pageIndex fromDataSource:(id<LeavesViewDataSource>)dataSource {
	NSNumber *pageIndexNumber = [NSNumber numberWithInt:pageIndex];
	UIImage *pageImage;
	@synchronized (pageCache) {
		pageImage = [pageCache objectForKey:pageIndexNumber];
	}
	if (!pageImage) {
		CGImageRef pageCGImage = [super freshImageForPageIndex:pageIndex fromDataSource:dataSource];
		pageImage = [UIImage imageWithCGImage:pageCGImage];
		@synchronized (pageCache) {
			[pageCache setObject:pageImage forKey:pageIndexNumber];
		}
//		if ([NSThread isMainThread])
//			NSLog(@"%u miss", pageIndex+1);
//		else {
//			NSLog(@"%u precache", pageIndex+1);
//		}
	}
	return pageImage.CGImage;
}

- (void) flush {
	@synchronized (pageCache) {
		[pageCache removeAllObjects];
	}
}

- (void) precacheImageForPageIndex:(NSUInteger)pageIndex  fromDataSource:(id<LeavesViewDataSource>)dataSource {
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:pageIndex], @"pageIndex",
						  dataSource, @"dataSource",
						  nil];
	[self performSelectorInBackground:@selector(precacheImageFor:)
						   withObject:info];
}

- (void) minimizeToPageIndex:(NSUInteger)pageIndex {
	/* Uncache all pages except previous, current, and next. */
	@synchronized (pageCache) {
		for (NSNumber *key in [pageCache allKeys])
			if (ABS([key intValue] - (int)pageIndex) > 2)
				[pageCache removeObjectForKey:key];
	}
}

@end
