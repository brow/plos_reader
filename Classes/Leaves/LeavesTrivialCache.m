//
//  LeavesTrivialCache.m
//  Reader
//
//  Created by Tom Brow on 5/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LeavesTrivialCache.h"

@implementation LeavesTrivialCache

@synthesize pageSize;

- (id) init
{
	if ([super init]) {
		pageSize = CGSizeZero;
	}
	return self;
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

#pragma mark LeavesViewCache methods


- (CGImageRef) imageForPageAtIndex:(NSUInteger)pageIndex fromDataSource:(id<LeavesViewDataSource>)dataSource {
	return [self freshImageForPageIndex:pageIndex fromDataSource:dataSource];
}

- (void) flush {
}

@end
