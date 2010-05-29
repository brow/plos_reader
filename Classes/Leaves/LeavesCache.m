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

@synthesize pageSize;

- (id) initWithPageSize:(CGSize)aPageSize
{
	if ([super init]) {
		pageSize = aPageSize;
		pageCache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[pageCache release];
	[super dealloc];
}

- (CGImageRef) freshImageForPageIndex:(NSUInteger)pageIndex fromDataSource:(id<LeavesViewDataSource>)dataSource {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, 
												 pageSize.width, 
												 pageSize.height, 
												 8,						/* bits per component*/
												 pageSize.width * 4, 	/* bytes per row */
												 colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextClipToRect(context, CGRectMake(0, 0, pageSize.width, pageSize.height));
	
	[dataSource renderPageAtIndex:pageIndex inContext:context];
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	[UIImage imageWithCGImage:image];
	CGImageRelease(image);
	
	return image;
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
		CGImageRef pageCGImage = [self freshImageForPageIndex:pageIndex fromDataSource:dataSource];
		pageImage = [UIImage imageWithCGImage:pageCGImage];
		@synchronized (pageCache) {
			[pageCache setObject:pageImage forKey:pageIndexNumber];
		}
		if ([NSThread isMainThread])
			NSLog(@"%u miss", pageIndex+1);
		else {
			NSLog(@"%u precache", pageIndex+1);
		}
		
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
