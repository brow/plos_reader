//
//  CitationViewController.h
//  Reader
//
//  Created by Tom Brow on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Citation.h"

@protocol CitationViewControllerDelegate;


@interface CitationViewController : UIViewController {
	UILabel *textView;
	UIButton *openButton, *emailButton, *copyButton;
	
	Citation *citation;
	id<CitationViewControllerDelegate> delegate;
}

@property (retain, nonatomic) IBOutlet UILabel *textView;
@property (retain, nonatomic) IBOutlet UIButton *openButton, *emailButton, *copyButton;
@property (retain) Citation *citation;
@property (assign) id<CitationViewControllerDelegate> delegate;

- (IBAction) openCitation:(id)sender;
- (IBAction) emailCitation:(id)sender;
- (IBAction) copyCitation:(id)sender;

@end


@protocol CitationViewControllerDelegate

- (void) citationViewController:(CitationViewController *)citationViewController didOpenCitation:(Citation *)aCitation;
- (void) citationViewController:(CitationViewController *)citationViewController didEmailCitation:(Citation *)aCitation;
- (void) citationViewController:(CitationViewController *)citationViewController didCopyCitation:(Citation *)aCitation;

@end