//
//  Paper.h
//  Reader
//
//  Created by Tom Brow on 4/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Paper : NSObject {
	NSURL *pdfUrl;
	NSString *title, *authors;
}

@property (retain) NSURL *pdfUrl;
@property (retain) NSString *title;
@property (retain) NSString *authors;

@end
