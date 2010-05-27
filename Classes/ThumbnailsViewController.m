//
//  ThumbnailsViewController.m
//  Reader
//
//  Created by Tom Brow on 5/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailsViewController.h"
#import "Utilities.h"

@implementation ThumbnailsViewController

@synthesize thumbnailCell;

- (id)initWithPaper:(Paper *)aPaper {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		paper = [aPaper retain];
		thumbnails = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
	[thumbnails release];
	[paper release];
	[super dealloc];
}

- (void) renderPage:(CGPDFPageRef)page inContext:(CGContextRef)ctx {
	CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);		
	CGRect croppedRect = CGRectInset(pageRect, 46, 44);
	croppedRect.origin.y -= 2;
	CGAffineTransform transform = aspectFit(croppedRect,
											CGContextGetClipBoundingBox(ctx));
	CGRect clipRect = CGRectApplyAffineTransform(croppedRect, transform);
	
	CGContextSaveGState(ctx);
	CGContextClipToRect(ctx, clipRect);
	CGContextConcatCTM(ctx, transform);
	CGContextDrawPDFPage(ctx, page);
	CGContextRestoreGState(ctx);	
}

- (UIImage *) thumbnailForPage:(CGPDFPageRef)page {
	CGSize thumbnailSize = CGSizeMake(100, 125);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, 
												 thumbnailSize.width, 
												 thumbnailSize.height, 
												 8,						/* bits per component*/
												 thumbnailSize.width * 4, 	/* bytes per row */
												 colorSpace, 
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextClipToRect(context, CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height));
	
	[self renderPage:page inContext:context];
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *ret = [UIImage imageWithCGImage:image];
	CGImageRelease(image);
	
	return ret;
}

- (void) didRenderThumbnail:(UIImage *)thumbnail {
	[thumbnails addObject:thumbnail];
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:
											[NSIndexPath indexPathForRow:thumbnails.count-1 
														  inSection:0]] 
						  withRowAnimation:UITableViewRowAnimationFade];
}

- (void) renderThumbnails {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:paper.localPDFPath]);
	for (int i = 0; i < CGPDFDocumentGetNumberOfPages(pdf); i++)
		[self performSelectorOnMainThread:@selector(didRenderThumbnail:) 
							   withObject:[self thumbnailForPage:CGPDFDocumentGetPage(pdf, i+1)]
							waitUntilDone:NO];
	CGPDFDocumentRelease(pdf);
	
	[pool release];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:paper.localPDFPath]);
	NSUInteger ret = CGPDFDocumentGetNumberOfPages(pdf);
	CGPDFDocumentRelease(pdf);
	return ret;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ThumbnailCell";
    
    ThumbnailCell *cell = (ThumbnailCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"ThumbnailCell" 
									  owner:self 
									options:nil];
        cell = self.thumbnailCell;
    }
	
	cell.pageNumberLabel.text = [NSString stringWithFormat:@"%u", indexPath.row+1];
	
	if (thumbnails.count > indexPath.row)
		cell.thumbImageView.image = [thumbnails objectAtIndex:indexPath.row];
	else
		cell.thumbImageView.image = nil;

	
    return cell;
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 150.0;
}

//- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    detailViewController.paper = [feed.papers objectAtIndex:indexPath.row];
//}

#pragma mark UIViewController methods

- (void) viewDidLoad {
	[super viewDidLoad];
	UIView *backgroundView = [[[UIView alloc] init] autorelease];
//	backgroundView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.tableView.backgroundView = backgroundView;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self performSelectorInBackground:@selector(renderThumbnails) withObject:nil];
}

@end
