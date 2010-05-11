//
//  Paper+Saving.m
//  Reader
//
//  Created by Tom Brow on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Paper+Saving.h"

static SavedPapersManager *savedPapersManager;

@implementation Paper(Saving)

+ (NSString *) documentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *) savedPapersDirectory {
	return [[self documentsDirectory] stringByAppendingPathComponent:@"saved"];
}

+ (NSString *) autosavedPaperDirectory {
	return [[self documentsDirectory] stringByAppendingPathComponent:@"autosaved"];
}

+ (NSString *) autosavedXMLPath {
	return [[self autosavedPaperDirectory] stringByAppendingPathComponent:@"paper.xml"];
}

+ (NSString *) autosavedPDFPath {
	return [[self autosavedPaperDirectory] stringByAppendingPathComponent:@"paper.pdf"];
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
	
	[[Paper savedPapersManager] willChangeValueForKey:@"savedPapers" 
									  withSetMutation:NSKeyValueUnionSetMutation 
										 usingObjects:[NSSet setWithObject:self]];
	[[NSFileManager defaultManager] copyItemAtPath:localPDFPath 
											toPath:self.permanentPDFPath 
											 error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:localXMLPath
											toPath:self.permanentXMLPath 
											 error:nil];
	[[Paper savedPapersManager] didChangeValueForKey:@"savedPapers" 
									 withSetMutation:NSKeyValueUnionSetMutation 
											usingObjects:[NSSet setWithObject:self]];
}

- (void) unsave {	
	[[Paper savedPapersManager] willChangeValueForKey:@"savedPapers" 
									  withSetMutation:NSKeyValueMinusSetMutation 
										 usingObjects:[NSSet setWithObject:self]];
	[[NSFileManager defaultManager] removeItemAtPath:self.permanentPDFPath error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:self.permanentXMLPath error:nil];
	[[Paper savedPapersManager] didChangeValueForKey:@"savedPapers" 
									 withSetMutation:NSKeyValueMinusSetMutation 
										usingObjects:[NSSet setWithObject:self]];
}

- (void) restore {
	[[NSFileManager defaultManager] copyItemAtPath:self.permanentPDFPath 
											toPath:localPDFPath 
											 error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:self.permanentXMLPath 
											toPath:localXMLPath 
											 error:nil];
	
	[self parsePaperXML:[NSData dataWithContentsOfFile:localXMLPath]];
	
	pdfDownloaded = YES;
	xmlDownloaded = YES;
	[self setValue:[NSNumber numberWithInt:StatusDownloaded] 
			forKey:@"downloadStatus"];
}

- (void) autosave {
	if (self.downloadStatus == StatusDownloaded) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:[self.class autosavedPaperDirectory]])
			[[NSFileManager defaultManager] createDirectoryAtPath:[self.class autosavedPaperDirectory]
													   attributes:nil];

		[[NSFileManager defaultManager] removeItemAtPath:[Paper autosavedPDFPath] error:nil];
		[[NSFileManager defaultManager] removeItemAtPath:[Paper autosavedXMLPath] error:nil];
		
		[[NSFileManager defaultManager] copyItemAtPath:localPDFPath 
												toPath:[Paper autosavedPDFPath]
												 error:nil];
		[[NSFileManager defaultManager] copyItemAtPath:localXMLPath 
												toPath:[Paper autosavedXMLPath]
												 error:nil];
	}
}

+ (Paper *) autosavedPaper {
	if ([[NSFileManager defaultManager] fileExistsAtPath:[Paper autosavedXMLPath]] &&
		[[NSFileManager defaultManager] fileExistsAtPath:[Paper autosavedPDFPath]]) 
	{
		NSData *xmlData = [NSData dataWithContentsOfFile:[Paper autosavedXMLPath]];
		Paper *paper = [[[Paper alloc] initWithPaperXML:xmlData] autorelease];
		
		[[NSFileManager defaultManager] copyItemAtPath:[Paper autosavedPDFPath]
												toPath:paper->localPDFPath 
												 error:nil];
		[[NSFileManager defaultManager] copyItemAtPath:[Paper autosavedXMLPath]
												toPath:paper->localXMLPath 
												 error:nil];
		
		paper->pdfDownloaded = YES;
		paper->xmlDownloaded = YES;
		[paper setValue:[NSNumber numberWithInt:StatusDownloaded] 
				 forKey:@"downloadStatus"];
		
		return paper;
	}
	else
		return nil;
}

+ (SavedPapersManager *) savedPapersManager {
	if (!savedPapersManager)
		savedPapersManager = [[SavedPapersManager alloc] init];
	return savedPapersManager;
}

@end

@implementation SavedPapersManager									  
									  
- (NSSet *) savedPapers {
	NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[Paper savedPapersDirectory] 
																			 error:nil];
	NSMutableSet *savedPapers = [NSMutableSet set];
	for (NSString *filename in filenames)
		if ([filename.pathExtension isEqualToString:@"xml"]) {
			NSString *xmlPath = [[Paper savedPapersDirectory] stringByAppendingPathComponent:filename];
			NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];
			[savedPapers addObject:[[[Paper alloc] initWithPaperXML:xmlData] autorelease]];
		}
	return savedPapers;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
	return NO;
}

@end