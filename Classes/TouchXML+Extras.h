//
//  DDXMLExtensions.h
//  Gifts
//
//  Created by Tom Brow on 3/31/09.
//  Copyright 2009 Tom Brow. All rights reserved.
//

#import "TouchXML.h"

@interface CXMLNode (Extras)

- (NSString *)flatStringForXPath:(NSString *)xpath namespaceMappings:(NSDictionary*)namespaceMappings;
- (NSData *)xmlDataForXPath:(NSString *)xpath namespaceMappings:(NSDictionary*)namespaceMappings;
- (BOOL) hasValueForXPath:(NSString *)xpath namespaceMappings:(NSDictionary*)namespaceMappings;

@end
