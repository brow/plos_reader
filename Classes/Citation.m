//
//  Citation.m
//  Reader
//
//  Created by Tom Brow on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Citation.h"
#import "TouchXML+Extras.h"

@implementation Citation

- (id) initWithXML:(NSData *)citationXML {
	if (self = [super init]) {
		metadata = [[NSMutableDictionary alloc] init];
		
		[self parseCitationXML:citationXML];
	}
	return self;
}

- (void) dealloc {
	[metadata release];
	[super dealloc];
}

- (void) parseCitationXML:(NSData *)xmlData {
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithData:xmlData
													options:CXMLDocumentTidyXML 
													  error:nil] autorelease];
	
	if ([doc hasValueForXPath:@"citation/source"  namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:@"citation/source" 
								 namespaceMappings:nil] 
					forKey:@"source"];

	if ([doc hasValueForXPath:@"citation/year"  namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:@"citation/year" 
								 namespaceMappings:nil]
					forKey:@"year"];
	
	if ([doc hasValueForXPath:@"citation/article-title"  namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:@"citation/article-title" 
								 namespaceMappings:nil]
					forKey:@"article-title"];
	
	if ([doc hasValueForXPath:@"citation/volume"  namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:@"citation/volume" 
								 namespaceMappings:nil]
					forKey:@"volume"];
		
	if ([doc hasValueForXPath:@"citation/fpage"  namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:@"citation/fpage" 
								 namespaceMappings:nil]
					forKey:@"first-page"];
		
	if ([doc hasValueForXPath:@"citation/lpage"  namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:@"citation/lpage" 
								 namespaceMappings:nil]
					forKey:@"last-page"];
	
	if ([doc hasValueForXPath:@"citation/publisher-name"  namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:@"citation/publisher-name" 
								 namespaceMappings:nil]
					forKey:@"publisher-name"];
		
	if ([doc hasValueForXPath:@"citation/publisher-loc"  namespaceMappings:nil])
		[metadata setValue:[doc flatStringForXPath:@"citation/publisher-loc" 
								 namespaceMappings:nil]
					forKey:@"publisher-loc"];

	
	
	NSMutableArray *authorsMetadata = [NSMutableArray array];
	for (CXMLNode *authorNode in [doc nodesForXPath:
				@"citation/person-group[@person-group-type='author']/name[@name-style='western']" error:nil]) {
		[authorsMetadata addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									[authorNode flatStringForXPath:@"./surname" namespaceMappings:nil], @"surname",
									[authorNode flatStringForXPath:@"./given-names" namespaceMappings:nil], @"given-names",
									nil]];
	}
	[metadata setValue:authorsMetadata forKey:@"authors"];
}

- (NSString *) citationString {
	NSMutableString *citationString = [NSMutableString string];
	
	NSArray *authorsArr = [metadata objectForKey:@"authors"];
	for (NSDictionary *author in authorsArr)
		if ([authorsArr indexOfObject:author] < 5)
			[citationString appendFormat:@"%@ %@%@", 
			 [author objectForKey:@"surname"], 
			 [author objectForKey:@"given-names"],
			 ([authorsArr indexOfObject:author] < authorsArr.count-1) ? @", " : @" "];
	
	if (authorsArr.count > 5)
		[citationString appendString:@"et al. "];
	
	
	if ([metadata valueForKey:@"year"])
		[citationString appendFormat:@"(%@) ",
		 [metadata objectForKey:@"year"]];
	
	if ([metadata valueForKey:@"article-title"])
		[citationString appendFormat:@"%@ ",
		 [metadata objectForKey:@"article-title"]];
	
	if ([metadata valueForKey:@"source"] ) {
		if ([metadata objectForKey:@"volume"]) {
			[citationString appendFormat:@"%@ %@: ",
			 [metadata objectForKey:@"source"],
			 [metadata objectForKey:@"volume"]
			 ];
			
			if ([metadata objectForKey:@"last-page"])
				[citationString appendFormat:@"%@-%@.",
				 [metadata objectForKey:@"first-page"],
				 [metadata objectForKey:@"last-page"]];
			else if ([metadata objectForKey:@"first-page"])
				[citationString appendFormat:@"%@.",
				 [metadata objectForKey:@"first-page"]];
		}
		else if ([metadata objectForKey:@"publisher-loc"] && [metadata objectForKey:@"publisher-name"]){
			[citationString appendFormat:@"%@. %@: %@.",
			 [metadata objectForKey:@"source"],
			 [metadata objectForKey:@"publisher-loc"],
			 [metadata objectForKey:@"publisher-name"]
			 ];
		}
	}

	return citationString;
}

@end
