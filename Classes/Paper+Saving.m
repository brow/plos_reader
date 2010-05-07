//
//  Paper+Saving.m
//  Reader
//
//  Created by Tom Brow on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Paper+Saving.h"


@implementation Paper(Saving)

+ (NSString *) documentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *) savedPapersDirectory {
	return [[self documentsDirectory] stringByAppendingPathComponent:@"saved"];
}

- (NSString *)filenameBase {
	assert(self.doi);
	return [self.doi stringByReplacingOccurrencesOfString:@"/" 
											   withString:@"_"];
}

- (NSString *) permanentPDFPath {
	return [[self.class savedPapersDirectory] stringByAppendingPathComponent:
			[[self filenameBase] stringByAppendingPathExtension:@"pdf"]];
}

- (NSString *) permanentXMLPath {
	return [[self.class savedPapersDirectory] stringByAppendingPathComponent:
			[[self filenameBase] stringByAppendingPathExtension:@"xml"]];
}

- (BOOL) saved {
	return	[[NSFileManager defaultManager] fileExistsAtPath:self.permanentPDFPath] &&
			[[NSFileManager defaultManager] fileExistsAtPath:self.permanentXMLPath];
}

- (void) save {
	assert(self.downloadStatus == StatusDownloaded);
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self.class savedPapersDirectory]])
		[[NSFileManager defaultManager] createDirectoryAtPath:[self.class savedPapersDirectory]
												   attributes:nil];
	
	[[NSFileManager defaultManager] copyItemAtPath:localPDFPath 
											toPath:self.permanentPDFPath 
											 error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:localXMLPath
											toPath:self.permanentXMLPath 
											 error:nil];
}

- (void) restore {
	[localPDFPath release];
	localPDFPath = [self.permanentPDFPath retain];
	[localXMLPath release];
	localXMLPath = [self.permanentXMLPath retain];
	
	pdfDownloaded = YES;
	xmlDownloaded = YES;
	[self setValue:[NSNumber numberWithInt:StatusDownloaded] 
			forKey:@"downloadStatus"];
}

+ (NSArray *) savedPapers {
	NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self savedPapersDirectory] 
																			 error:nil];
	NSMutableArray *savedPapers = [NSMutableArray array];
	for (NSString *filename in filenames)
		if ([filename.pathExtension isEqualToString:@"xml"]) {
			NSString *xmlPath = [self.savedPapersDirectory stringByAppendingPathComponent:filename];
			NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
			[savedPapers addObject:[[[Paper alloc] initWithPaperXML:xmlData] autorelease]];
		}
	return savedPapers;
}

@end
