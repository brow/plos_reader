//
//  LeavesView.h
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class LeavesCache;

@protocol LeavesViewDataSource;
@protocol LeavesViewDelegate;
@protocol LeavesViewCache;

@interface LeavesView : UIView {
	CALayer *topPage;
	CALayer *topPageImage;
	CALayer *topPageOverlay;
	CAGradientLayer *topPageShadow;
	
	CALayer *topPageReverse;
	CALayer *topPageReverseImage;
	CALayer *topPageReverseOverlay;
	CAGradientLayer *topPageReverseShading;
	
	CALayer *bottomPage;
	CALayer *bottomPageImage;
	CAGradientLayer *bottomPageShadow;
	
	CGFloat leafEdge;
	NSUInteger currentPageIndex;
	NSUInteger numberOfPages;
	
	id<LeavesViewDataSource> dataSource;
	id<LeavesViewDelegate> delegate;
	id<LeavesViewCache> cache;
	
	CGSize pageResolution;
	CGFloat preferredTargetWidth;
	LeavesCache *defaultCache;
	BOOL backgroundRendering;
	
	CGPoint touchBeganPoint;
	BOOL touchIsActive;
	CGRect nextPageRect, prevPageRect;
	BOOL interactionLocked;
}

@property (retain) id<LeavesViewCache> cache;
@property (assign) id<LeavesViewDataSource> dataSource;
@property (assign) id<LeavesViewDelegate> delegate;

// the automatically determined width of the interactive areas on either side of the page
@property (readonly) CGFloat targetWidth;
@property (assign) CGFloat preferredTargetWidth;

// the zero-based index of the page currently being displayed.
@property (assign) NSUInteger currentPageIndex;

// If backgroundRendering is YES, some pages not currently being displayed will be pre-rendered in background threads.
// The default value is NO.  Only set this to YES if your implementation of the data source methods is thread-safe.
@property (assign) BOOL backgroundRendering;

@property (assign) CGSize pageResolution;

// refreshes the contents of all pages via the data source methods, much like -[UITableView reloadData]
- (void) reloadData;

@end


@protocol LeavesViewDataSource <NSObject>

- (NSUInteger) numberOfPagesInLeavesView:(LeavesView*)leavesView;
- (void) renderPageAtIndex:(NSUInteger)index inContext:(CGContextRef)ctx;

@end


@protocol LeavesViewDelegate <NSObject>

@optional

// called when the user touches up on the left or right side of the page, or finishes dragging the page
- (void) leavesView:(LeavesView *)leavesView willTurnToPageAtIndex:(NSUInteger)pageIndex;

// called when the page-turn animation (following a touch-up or drag) completes 
- (void) leavesView:(LeavesView *)leavesView didTurnToPageAtIndex:(NSUInteger)pageIndex;

@end


@protocol LeavesViewCache <NSObject>

@property (assign) CGSize pageSize;
- (CGImageRef) imageForPageAtIndex:(NSUInteger)index fromDataSource:(id<LeavesViewDataSource>)dataSource;
- (void) flush;

@optional

- (void) precacheImageForPageIndex:(NSUInteger)index fromDataSource:(id<LeavesViewDataSource>)dataSource;
- (void) minimizeToPageIndex:(NSUInteger)index;

@end