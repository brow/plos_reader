//
//  FigureViewController.h
//  Reader
//
//  Created by Tom Brow on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FigureViewController : UIViewController <UIScrollViewDelegate> {
	UIImageView *imageView;
	UIScrollView *scrollView;
	
	UIImage *figureImage;
}

@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain) UIImage *figureImage;

@end
