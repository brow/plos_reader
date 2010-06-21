//
//  Paper+DeepDyve.m
//  Reader
//
//  Created by Tom Brow on 6/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Paper+DeepDyve.h"
#import "TouchXML+Extras.h"

@implementation Paper(DeepDyve)


- (void) parseDeepDyveHTMLNode:(id)node {
	NSDictionary *ns = [NSDictionary dictionaryWithObject:@"http://www.w3.org/1999/xhtml" 
												   forKey:@"x"];
	
	NSString *url = [node flatStringForXPath:@"./x:p[@class='externalUrl']" namespaceMappings:ns];
	NSString *trimmedUrl = [url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSRange doiRange = [trimmedUrl rangeOfString:@"[\\d\\.]*/journal\\..*" options:NSRegularExpressionSearch];
	if (doiRange.location != NSNotFound)
		[metadata setValue:[trimmedUrl substringWithRange:doiRange] forKey:@"doi"];
	
	NSString *escapedUrl = [node flatStringForXPath:@"./x:h2/x:a/@href" namespaceMappings:ns];
	NSRange baseRange = [escapedUrl rangeOfString:@"http://.*/article/" options:NSRegularExpressionSearch];
	if (baseRange.location != NSNotFound) {
		NSString *base = [escapedUrl substringWithRange:baseRange];
		NSString *infoDoi = [escapedUrl substringFromIndex:(baseRange.location+baseRange.length)];
		NSString *resourceURL = [NSString stringWithFormat:@"%@fetchObjectAttachment.action?uri=%@&representation=",
								 base,
								 infoDoi];
		self.remotePDFUrl = [NSURL URLWithString:[resourceURL stringByAppendingString:@"PDF"]];
		self.remoteXMLUrl = [NSURL URLWithString:[resourceURL stringByAppendingString:@"XML"]];
	}
		
	
	[metadata setValue:[node flatStringForXPath:@"./x:h2/x:a" namespaceMappings:ns] 
				forKey:@"title"];
	
	NSMutableArray *authorsMetadata = [NSMutableArray array];
	for (CXMLNode *authorNode in [node nodesForXPath:@"./x:dl[@class='meta1']/x:dd/x:a" namespaceMappings:ns error:nil]) {
		NSString *fullName = [authorNode flatStringForXPath:@"." namespaceMappings:ns];
		NSArray *names = [fullName componentsSeparatedByString:@", "];
		[authorsMetadata addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									[names objectAtIndex:1], @"surname",
									[names objectAtIndex:0], @"given-names",
									nil]];
	}
	[metadata setValue:authorsMetadata forKey:@"authors"];
}

- (id) initWithDeepDyveHTMLNode:(id)node {
	if (self = [self init]) {
		[self parseDeepDyveHTMLNode:node];
	}
	return self;
}

@end
