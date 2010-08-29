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

@synthesize paper;

- (void) awakeFromNib {
	super.delegate = self;
}

- (void) dealloc {
	[paper release];
	[super dealloc];
}

- (void) loadPaperXMLFile:(NSString *)xmlFile {		
	NSMutableString *docString = [NSMutableString stringWithContentsOfFile:xmlFile
													encoding:NSUTF8StringEncoding 
													   error:nil];
	
	// Add a reference to our XSLT stylesheet
	NSString *stylesheetString = [NSString stringWithFormat:@"<?xml-stylesheet type='text/xsl' href='plos.xsl'?>"];
	
	// Remove the DOCTYPE so we don't get slow-ass validated parsing
	[docString replaceOccurrenceOfPattern:@"(?s:<!DOCTYPE.*?>)" 
							   withString:stylesheetString];

	[super loadData:[docString dataUsingEncoding:NSUTF8StringEncoding] 
		   MIMEType:@"text/xml" 
   textEncodingName:@"utf-8" 
			baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (void) configureView {
	if (paper.downloadStatus == StatusDownloaded)
		super.alpha = 1;
	else
		super.alpha = 0;
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
		[self loadPaperXMLFile:paper.localXMLPath];
	[paper addObserver:self 
			forKeyPath:@"downloadStatus" 
			   options:NSKeyValueObservingOptionNew 
			   context:nil];
}

#pragma mark NSKeyValueObserving methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (paper.downloadStatus == StatusDownloaded)
		[self loadPaperXMLFile:paper.localXMLPath];
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
@end
