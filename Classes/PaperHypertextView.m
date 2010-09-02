//
//  PaperHypertextView.m
//  Reader
//
//  Created by Tom Brow on 8/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PaperHypertextView.h"
#import "Utilities.h"
#import "TouchXML.h"
#import "NSMutableString+Extras.h"

@implementation PaperHypertextView

@synthesize paper, hypertextDelegate;

- (void) awakeFromNib {
	super.delegate = self;
}

- (void) dealloc {
	[paper release];
	[super dealloc];
}

- (void) loadPaper {
	NSMutableString *docString = [NSMutableString stringWithContentsOfFile:paper.localXMLPath
													encoding:NSUTF8StringEncoding 
													   error:nil];
	
	// Add a reference to our XSLT stylesheet, and link it into the directory
	NSString *stylesheetString = [NSString stringWithFormat:@"<?xml-stylesheet type='text/xsl' href='plos.xsl'?>"];
	[[NSFileManager defaultManager] createSymbolicLinkAtPath:[paper.localDirectory stringByAppendingPathComponent:@"plos.xsl"]
										 withDestinationPath:[[NSBundle mainBundle] pathForResource:@"plos" ofType:@"xsl"] 
													   error:nil];
	
	// Link in jquery.js
	[[NSFileManager defaultManager] createSymbolicLinkAtPath:[paper.localDirectory stringByAppendingPathComponent:@"jquery.js"] 
										 withDestinationPath:[[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"] 
														error:nil];
	
	// Remove the DOCTYPE so we don't get slow-ass validated parsing
	[docString replaceOccurrenceOfPattern:@"(?s:<!DOCTYPE.*?>)" 
							   withString:stylesheetString];

	[super loadData:[docString dataUsingEncoding:NSUTF8StringEncoding] 
		   MIMEType:@"text/xml" 
   textEncodingName:@"utf-8" 
			baseURL:[NSURL fileURLWithPath:paper.localDirectory]];
}

- (void) configureView {
	if (paper.downloadStatus == StatusDownloaded)
		super.alpha = 1;
	else
		super.alpha = 0;
}

- (CGRect) rectOfElementWithId:(NSString *)elementId {
	CGFloat documentWidth = [[super stringByEvaluatingJavaScriptFromString:@"$(window).width();"] floatValue];
	CGFloat scale = super.bounds.size.width / documentWidth;
	
	CGRect ret;
	ret.origin.x = floorf([[super stringByEvaluatingJavaScriptFromString:
							[NSString stringWithFormat:
							 @"$('#%@').offset().left;",
							 elementId]] floatValue] * scale);
	ret.origin.y = floorf([[super stringByEvaluatingJavaScriptFromString:
							[NSString stringWithFormat:
							 @"$('#%@').offset().top-2*$(window).scrollTop();",
							 elementId]] floatValue] * scale);
	ret.size.width = floorf([[super stringByEvaluatingJavaScriptFromString:
							  [NSString stringWithFormat:
							   @"$('#%@').width();",
							   elementId]] floatValue] * scale);
	ret.size.height = floorf([[super stringByEvaluatingJavaScriptFromString:
							   [NSString stringWithFormat:
								@"$('#%@').height();",
								elementId]] floatValue] * scale);
	return ret;
}

#pragma mark accessors

- (CGFloat) scrollPosition {
	return [[super stringByEvaluatingJavaScriptFromString: @"window.pageYOffset"] floatValue];
}

- (void) setScrollPosition:(CGFloat)value {
	NSString *js  = [NSString stringWithFormat:@"window.scrollTo(0, %.0f)",value];
	[super stringByEvaluatingJavaScriptFromString:js];
}

- (void) setPaper:(Paper *)value {
	[paper removeObserver:self forKeyPath:@"downloadStatus"];
	
	[paper autorelease];
	paper = [value retain];
	
	if (paper.downloadStatus == StatusDownloaded)
		[self loadPaper];
	[paper addObserver:self 
			forKeyPath:@"downloadStatus" 
			   options:NSKeyValueObservingOptionNew 
			   context:nil];
}

#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (paper.downloadStatus == StatusDownloaded)
		[self loadPaper];
}

#pragma mark UIWebViewDelegate methods 

- (void)webViewDidStartLoad:(UIWebView *)webView {
	super.alpha = 0;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	super.alpha = 1;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
}

- (BOOL)webView:(UIWebView *)webView 
shouldStartLoadWithRequest:(NSURLRequest *)aRequest 
 navigationType:(UIWebViewNavigationType)navigationType {	
	if (navigationType == UIWebViewNavigationTypeOther)
		return YES;
	else if ([aRequest.URL isFileURL]) {
		[hypertextDelegate paperHypertextView:self 
						   selectedImageAtURL:aRequest.URL 
										 rect:[self rectOfElementWithId:[aRequest.URL fragment]]];
		return NO;
	}
	else if ([[aRequest.URL scheme] isEqualToString:@"reference"]) {
		[hypertextDelegate paperHypertextView:self 
						  selectedReferenceId:[[aRequest.URL path] lastPathComponent] 
										 rect:[self rectOfElementWithId:[aRequest.URL fragment]]];
		return NO;
	}
	else if ([[aRequest.URL scheme] isEqualToString:@"mailto"]) {
		NSString *recipient = [[aRequest.URL relativeString] stringByReplacingOccurrencesOfString:@"mailto:" 
																					   withString:@""];
		[hypertextDelegate paperHypertextView:self 
						 selectedEmailAddress:recipient 
										 rect:CGRectZero];
		return NO;
	}
	else
		return NO;
}

@end
