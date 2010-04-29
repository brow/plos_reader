//
//  DDXMLExtensions.m
//  Gifts
//
//  Created by Tom Brow on 3/31/09.
//  Copyright 2009 Tom Brow. All rights reserved.
//

#import "TouchXML+Extras.h"
#import "XMLParsingException.h"

@implementation CXMLNode (Extras)

- (NSString *) flatStringValue {
	if (self.kind == CXMLTextKind)
		return [self stringValue];
	else {
		NSMutableString *string = [NSMutableString string];
		for (CXMLNode *child in self.children)
			[string appendString:[child flatStringValue]];
		return string;
	}
}

- (BOOL) hasValueForXPath:(NSString *)xpath namespaceMappings:(NSDictionary*)namespaceMappings {
	NSError *error = nil;
	NSArray *nodes = [self nodesForXPath:xpath 
					   namespaceMappings:namespaceMappings 
								   error:&error];
	return (!error && [nodes count] > 0);
}

- (NSString *)flatStringForXPath:(NSString *)xpath namespaceMappings:(NSDictionary*)namespaceMappings {
	NSError *error = nil;
	NSArray *nodes = [self nodesForXPath:xpath 
					   namespaceMappings:namespaceMappings 
								   error:&error];
	
	if (error || [nodes count] == 0)
		[XMLParsingException raise:@"Missing node at xpath" format:@"Path: %@",xpath];
	return [[nodes objectAtIndex:0] flatStringValue];
}

- (NSData *)xmlDataForXPath:(NSString *)xpath namespaceMappings:(NSDictionary*)namespaceMappings {
	NSError *error = nil;
	NSArray *nodes = [self nodesForXPath:xpath 
					   namespaceMappings:namespaceMappings 
								   error:&error];
	
	if (error || [nodes count] == 0)
		[XMLParsingException raise:@"Missing node at xpath" format:@"Path: %@",xpath];
	return [[[nodes objectAtIndex:0] XMLString] dataUsingEncoding:NSUTF8StringEncoding];
}

@end