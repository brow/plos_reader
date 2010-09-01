//
//  PaperHypertextView.h
//  Reader
//
//  Created by Tom Brow on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Paper.h"

@protocol PaperHypertextViewDelegate;


@interface PaperHypertextView : UIWebView <UIWebViewDelegate> {
	Paper *paper;
	id<PaperHypertextViewDelegate> hypertextDelegate;
}

@property (retain) Paper *paper;
@property (assign) CGFloat scrollPosition;
@property (assign) id<PaperHypertextViewDelegate> hypertextDelegate;

@end


@protocol PaperHypertextViewDelegate

- (void) paperHypertextView:(PaperHypertextView *)paperHypertextView selectedImageAtURL:(NSURL *)imageURL rect:(CGRect)rect;
- (void) paperHypertextView:(PaperHypertextView *)paperHypertextView selectedEmailAddress:(NSString *)emailAddress rect:(CGRect)rect;
- (void) paperHypertextView:(PaperHypertextView *)paperHypertextView selectedReferenceId:(NSString *)referenceId rect:(CGRect)rect;

@end
