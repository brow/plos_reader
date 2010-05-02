//
//  Feed.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Feed : NSObject {
	NSString *title;
	NSString *localXMLPath;
	NSURL *url;
	NSMutableArray *papers;
	NSString *imageName;
	BOOL downloaded;
}

@property (readonly) NSString *title;
@property (readonly) NSArray *papers;
@property (readonly) UIImage *image;
@property (readonly) BOOL downloaded;

+ (id) feedWithTitle:(NSString *)title URL:(NSString *)urlString imageName:(NSString *)aImageName;
- (id) initWithTitle:(NSString *)aTitle URL:(NSString *)urlString imageName:(NSString *)aImageName;
- (void) load;

@end
