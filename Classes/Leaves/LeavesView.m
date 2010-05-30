//
//  LeavesView.m
//  Leaves
//
//  Created by Tom Brow on 4/18/10.
//  Copyright 2010 Tom Brow. All rights reserved.
//

#import "LeavesView.h"
#import "LeavesCache.h"

@interface LeavesView () 

@property (assign) CGFloat leafEdge;

@end

CGFloat distance(CGPoint a, CGPoint b);

@implementation LeavesView

@synthesize delegate, dataSource, cache;
@synthesize leafEdge, currentPageIndex, backgroundRendering, pageResolution;

- (void) setUpLayers {
	self.clipsToBounds = YES;
	
	topPage = [[CALayer alloc] init];
	topPage.masksToBounds = YES;
	topPage.backgroundColor = [[UIColor whiteColor] CGColor];
	
	topPageImage = [[CALayer alloc] init];
	topPageImage.masksToBounds = YES;
	topPageImage.contentsGravity = kCAGravityResize;
	
	topPageOverlay = [[CALayer alloc] init];
	topPageOverlay.backgroundColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
	
	topPageShadow = [[CAGradientLayer alloc] init];
	topPageShadow.colors = [NSArray arrayWithObjects:
							(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
							(id)[[UIColor clearColor] CGColor],
							nil];
	topPageShadow.startPoint = CGPointMake(1,0.5);
	topPageShadow.endPoint = CGPointMake(0,0.5);
	
	topPageReverse = [[CALayer alloc] init];
	topPageReverse.backgroundColor = [[UIColor whiteColor] CGColor];
	topPageReverse.masksToBounds = YES;
	
	topPageReverseImage = [[CALayer alloc] init];
	topPageReverseImage.masksToBounds = YES;
	topPageReverseImage.contentsGravity = kCAGravityResize;
	
	topPageReverseOverlay = [[CALayer alloc] init];
	topPageReverseOverlay.backgroundColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.8] CGColor];
	
	topPageReverseShading = [[CAGradientLayer alloc] init];
	topPageReverseShading.colors = [NSArray arrayWithObjects:
									(id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
									(id)[[UIColor clearColor] CGColor],
									nil];
	topPageReverseShading.startPoint = CGPointMake(1,0.5);
	topPageReverseShading.endPoint = CGPointMake(0,0.5);
	
	bottomPage = [[CALayer alloc] init];
	bottomPage.backgroundColor = [[UIColor whiteColor] CGColor];
	bottomPage.masksToBounds = YES;
	
	bottomPageImage = [[CALayer alloc] init];
	bottomPageImage.masksToBounds = YES;
	bottomPageImage.contentsGravity = kCAGravityResize;
	
	bottomPageShadow = [[CAGradientLayer alloc] init];
	bottomPageShadow.colors = [NSArray arrayWithObjects:
							   (id)[[[UIColor blackColor] colorWithAlphaComponent:0.6] CGColor],
							   (id)[[UIColor clearColor] CGColor],
							   nil];
	bottomPageShadow.startPoint = CGPointMake(0,0.5);
	bottomPageShadow.endPoint = CGPointMake(1,0.5);
	
	[topPage addSublayer:topPageImage];
	[topPage addSublayer:topPageShadow];
	[topPage addSublayer:topPageOverlay];
	[topPageReverse addSublayer:topPageReverseImage];
	[topPageReverse addSublayer:topPageReverseOverlay];
	[topPageReverse addSublayer:topPageReverseShading];
	[bottomPage addSublayer:bottomPageImage];
	[bottomPage addSublayer:bottomPageShadow];
	[self.layer addSublayer:bottomPage];
	[self.layer addSublayer:topPage];
	[self.layer addSublayer:topPageReverse];
	
	self.leafEdge = 1.0;
	self.pageResolution = CGSizeZero;
}

- (void) initialize {
	backgroundRendering = NO;
	cache = defaultCache = [[LeavesCache alloc] initWithPageSize:
							CGSizeEqualToSize(pageResolution, CGSizeZero) ? self.bounds.size : pageResolution];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		[self setUpLayers];
		[self initialize];
    }
    return self;
}

- (void) awakeFromNib {
	[super awakeFromNib];
	[self setUpLayers];
	[self initialize];
}

- (void)dealloc {
	[topPage release];
	[topPageImage release];
	[topPageShadow release];
	[topPageOverlay release];
	[topPageReverse release];
	[topPageReverseImage release];
	[topPageReverseOverlay release];
	[topPageReverseShading release];
	[bottomPage release];
	[bottomPageImage release];
	[bottomPageShadow release];
	
	[defaultCache release];
	
    [super dealloc];
}

- (void) reloadData {
	[cache flush];
	numberOfPages = [dataSource numberOfPagesInLeavesView:self];
	self.currentPageIndex = 0;
}

- (void) precacheImageForPageIndex:(NSUInteger)pageIndex {
	if ([cache respondsToSelector:@selector(precacheImageForPageIndex:fromDataSource:)])
		[cache precacheImageForPageIndex:pageIndex fromDataSource:dataSource];
}

- (CGImageRef) cachedImageForPageIndex:(NSUInteger)pageIndex {
	return [cache imageForPageAtIndex:pageIndex fromDataSource:dataSource];
}

- (void) minimizeCacheToPageIndex:(NSUInteger)pageIndex {
	if ([cache respondsToSelector:@selector(minimizeToPageIndex:)])
		[cache minimizeToPageIndex:pageIndex];
}

- (void) getImages {
	if (currentPageIndex < numberOfPages) {
		[self minimizeCacheToPageIndex:currentPageIndex];
		if (currentPageIndex > 0 && backgroundRendering)
			[self precacheImageForPageIndex:currentPageIndex-1];
		topPageImage.contents = (id)[self cachedImageForPageIndex:currentPageIndex];
		topPageReverseImage.contents = (id)[self cachedImageForPageIndex:currentPageIndex];
		if (currentPageIndex < numberOfPages - 1)
			bottomPageImage.contents = (id)[self cachedImageForPageIndex:currentPageIndex + 1];
	} else {
		topPageImage.contents = nil;
		topPageReverseImage.contents = nil;
		bottomPageImage.contents = nil;
	}
}

- (void) setLayerFrames {
	topPage.frame = CGRectMake(self.layer.bounds.origin.x, 
							   self.layer.bounds.origin.y, 
							   leafEdge * self.bounds.size.width, 
							   self.layer.bounds.size.height);
	
	topPageReverse.frame = CGRectMake(self.layer.bounds.origin.x + (2*leafEdge-1) * self.bounds.size.width + 3, 
									  self.layer.bounds.origin.y, 
									  (1-leafEdge) * self.bounds.size.width, 
									  self.layer.bounds.size.height);
	bottomPage.frame = self.layer.bounds;
	
	topPageShadow.frame = CGRectMake(topPageReverse.frame.origin.x - 40, 
									 0, 
									 40, 
									 bottomPage.bounds.size.height);
	
	topPageReverseImage.transform = CATransform3DMakeScale(-1, 1, 1);
	topPageReverseOverlay.frame = topPageReverse.bounds;
	topPageReverseShading.frame = CGRectMake(topPageReverse.bounds.size.width - 50, 
											 0, 
											 50 + 1, 
											 topPageReverse.bounds.size.height);
	bottomPageShadow.frame = CGRectMake(leafEdge * self.bounds.size.width, 
										0, 
										40, 
										bottomPage.bounds.size.height);
	topPageOverlay.frame = topPage.bounds;
	
	if (CGSizeEqualToSize(pageResolution, CGSizeZero)) {
		topPageImage.frame = topPage.bounds;
		bottomPageImage.frame = bottomPage.bounds;
		topPageReverseImage.frame = topPageReverse.bounds;
	} else {
		CGFloat pageAspect = pageResolution.width / pageResolution.height;
		CGFloat viewAspect = self.bounds.size.width / self.bounds.size.height;
		CGFloat scaleX = 1.0, scaleY = 1.0;
		if (pageAspect < viewAspect)
			scaleX = pageAspect / viewAspect;
		else
			scaleY = viewAspect / pageAspect;
		
		topPageImage.frame = CGRectMake((1-scaleX) * self.bounds.size.width / 2,
										(1-scaleY) * self.bounds.size.height / 2,
										scaleX * self.bounds.size.width,
										scaleY * self.bounds.size.height);
		bottomPageImage.frame = CGRectMake((1-scaleX) * self.bounds.size.width / 2,
										   (1-scaleY) * self.bounds.size.height / 2,
										   scaleX * self.bounds.size.width,
										   scaleY * self.bounds.size.height);
		topPageReverseImage.frame = CGRectMake((1-scaleX) * self.bounds.size.width / 2,
											   (1-scaleY) * self.bounds.size.height / 2,
											   scaleX * self.bounds.size.width,
											   scaleY * self.bounds.size.height);
	}
}

- (void) willTurnToPageAtIndex:(NSUInteger)index {
	if ([delegate respondsToSelector:@selector(leavesView:willTurnToPageAtIndex:)])
		[delegate leavesView:self willTurnToPageAtIndex:index];
}

- (void) didTurnToPageAtIndex:(NSUInteger)index {
	if ([delegate respondsToSelector:@selector(leavesView:didTurnToPageAtIndex:)])
		[delegate leavesView:self didTurnToPageAtIndex:index];
}

- (void) didTurnPageBackward {
	interactionLocked = NO;
	[self didTurnToPageAtIndex:currentPageIndex];
}

- (void) didTurnPageForward {
	interactionLocked = NO;
	self.currentPageIndex = self.currentPageIndex + 1;	
	[self didTurnToPageAtIndex:currentPageIndex];
}

- (BOOL) hasPrevPage {
	return self.currentPageIndex > 0;
}

- (BOOL) hasNextPage {
	return self.currentPageIndex < numberOfPages - 1;
}

- (BOOL) touchedNextPage {
	return CGRectContainsPoint(nextPageRect, touchBeganPoint);
}

- (BOOL) touchedPrevPage {
	return CGRectContainsPoint(prevPageRect, touchBeganPoint);
}

- (CGFloat) dragThreshold {
	// Magic empirical number
	return 10;
}

- (CGFloat) targetWidth {
	// Magic empirical formula
	return MAX(28, self.bounds.size.width / 5);
}

#pragma mark accessors

- (void) setLeafEdge:(CGFloat)aLeafEdge {
	leafEdge = aLeafEdge;
	topPageShadow.opacity = MIN(1.0, 4*(1-leafEdge));
	bottomPageShadow.opacity = MIN(1.0, 4*leafEdge);
	topPageOverlay.opacity = MIN(1.0, 4*(1-leafEdge));
	[self setLayerFrames];
}

- (void) setCurrentPageIndex:(NSUInteger)aCurrentPageIndex {
	currentPageIndex = aCurrentPageIndex;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	
	[self getImages];
	
	self.leafEdge = 1.0;
	
	[CATransaction commit];
}

- (void) setPageResolution:(CGSize)aPageResolution {
	pageResolution = aPageResolution;
	cache.pageSize = CGSizeEqualToSize(pageResolution, CGSizeZero) ? self.bounds.size : pageResolution;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	[self setLayerFrames];
	[CATransaction commit];
}

#pragma mark UIView methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (interactionLocked)
		return;
	
	UITouch *touch = [event.allTouches anyObject];
	touchBeganPoint = [touch locationInView:self];
	
	if ([self touchedPrevPage] && [self hasPrevPage]) {		
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
		self.currentPageIndex = self.currentPageIndex - 1;
		self.leafEdge = 0.0;
		[CATransaction commit];
		touchIsActive = YES;		
	} 
	else if ([self touchedNextPage] && [self hasNextPage])
		touchIsActive = YES;
	
	else 
		touchIsActive = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!touchIsActive)
		return;
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.07]
					 forKey:kCATransactionAnimationDuration];
	self.leafEdge = touchPoint.x / self.bounds.size.width;
	[CATransaction commit];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!touchIsActive)
		return;
	touchIsActive = NO;
	
	UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self];
	BOOL dragged = distance(touchPoint, touchBeganPoint) > [self dragThreshold];
	
	[CATransaction begin];
	float duration;
	if ((dragged && self.leafEdge < 0.5) || (!dragged && [self touchedNextPage])) {
		[self willTurnToPageAtIndex:currentPageIndex+1];
		self.leafEdge = 0;
		duration = leafEdge;
		interactionLocked = YES;
		if (currentPageIndex+2 < numberOfPages && backgroundRendering)
			[self precacheImageForPageIndex:currentPageIndex+2];
		[self performSelector:@selector(didTurnPageForward)
				   withObject:nil 
				   afterDelay:duration + 0.25];
	}
	else {
		[self willTurnToPageAtIndex:currentPageIndex];
		self.leafEdge = 1.0;
		duration = 1 - leafEdge;
		interactionLocked = YES;
		[self performSelector:@selector(didTurnPageBackward)
				   withObject:nil 
				   afterDelay:duration + 0.25];
	}
	[CATransaction setValue:[NSNumber numberWithFloat:duration]
					 forKey:kCATransactionAnimationDuration];
	[CATransaction commit];
}

- (void) layoutSubviews {
	[super layoutSubviews];
		
	CGSize pageSize = CGSizeEqualToSize(pageResolution, CGSizeZero) ? self.bounds.size : pageResolution;
	if (!CGSizeEqualToSize(cache.pageSize, pageSize)) { 
		cache.pageSize = pageSize;
		[self getImages];
	}
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	[self setLayerFrames];
	[CATransaction commit];
	
	CGFloat touchRectsWidth = [self targetWidth];
	nextPageRect = CGRectMake(self.bounds.size.width - touchRectsWidth,
							  0,
							  touchRectsWidth,
							  self.bounds.size.height);
	prevPageRect = CGRectMake(0,
							  0,
							  touchRectsWidth,
							  self.bounds.size.height);
}

@end

CGFloat distance(CGPoint a, CGPoint b) {
	return sqrtf(powf(a.x-b.x, 2) + powf(a.y-b.y, 2));
}
