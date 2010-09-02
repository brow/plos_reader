//
//  Citation.h
//  Reader
//
//  Created by Tom Brow on 8/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Citation : NSObject {
	NSMutableDictionary *metadata;
}

@property (readonly) NSString *citationString;
@property (readonly) NSString *title;

- (id) initWithXML:(NSData *)xmlString;
- (void) parseCitationXML:(NSData *)xmlData;

@end
