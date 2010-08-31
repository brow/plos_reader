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
	return [[self documentsDirectory] stringByAppendingPathComponent:@"saved.2"];
}

+ (NSString *) autosavedPaperDirectory {
	return [[self documentsDirectory] stringByAppendingPathComponent:@"autosaved.2"];
}

- (NSString *)filenameBase {
	return [self.doi stringByReplacingOccurrencesOfString:@"/" 
											   withString:@"_"];
}

- (NSString *) permanentDirectory {
	return [[self.class savedPapersDirectory] stringByAppendingPathComponent:[self filenameBase]];
}

- (NSString *) permanentImagesDirectory {
	return [[self.class savedPapersDirectory] stringByAppendingPathComponent:@"images"];
}

- (BOOL) saved {
	return	[[NSFileManager defaultManager] fileExistsAtPath:self.permanentDirectory];
}

- (void) save {
	assert(self.downloadStatus == StatusDownloaded);
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self.class savedPapersDirectory]])
		[[NSFileManager defaultManager] createDirectoryAtPath:[self.class savedPapersDirectory]
												   attributes:nil];
	
	[[Paper savedPapersManager] willChangeValueForKey:@"savedPapers" 
									  withSetMutation:NSKeyValueUnionSetMutation 
										 usingObjects:[NSSet setWithObject:self]];
	[[NSFileManager defaultManager] copyItemAtPath:localDirectory 
											toPath:self.permanentDirectory 
											 error:nil];
	[[Paper savedPapersManager] didChangeValueForKey:@"savedPapers" 
									 withSetMutation:NSKeyValueUnionSetMutation 
											usingObjects:[NSSet setWithObject:self]];
}

- (void) unsave {	
	[[Paper savedPapersManager] willChangeValueForKey:@"savedPapers" 
									  withSetMutation:NSKeyValueMinusSetMutation 
										 usingObjects:[NSSet setWithObject:self]];
	[[NSFileManager defaultManager] removeItemAtPath:self.permanentDirectory error:nil];
	[[Paper savedPapersManager] didChangeValueForKey:@"savedPapers" 
									 withSetMutation:NSKeyValueMinusSetMutation 
										usingObjects:[NSSet setWithObject:self]];
}

- (void) restore {
	[[NSFileManager defaultManager] copyItemAtPath:self.permanentDirectory
											toPath:localDirectory 
											 error:nil];
	
	[self parsePaperXML:[NSData dataWithContentsOfFile:self.localXMLPath]];
	
	[self setValue:[NSNumber numberWithInt:StatusDownloaded] 
			forKey:@"downloadStatus"];
}

- (void) autosave {
	if (self.downloadStatus == StatusDownloaded) {
		if (![[NSFileManager defaultManager] fileExistsAtPath:[self.class autosavedPaperDirectory]])
			[[NSFileManager defaultManager] createDirectoryAtPath:[self.class autosavedPaperDirectory]
													   attributes:nil];

		[[NSFileManager defaultManager] removeItemAtPath:[Paper autosavedPaperDirectory] error:nil];
		[[NSFileManager defaultManager] copyItemAtPath:localDirectory 
												toPath:[Paper autosavedPaperDirectory]
												 error:nil];
	}
}

+ (Paper *) autosavedPaper {
	if ([[NSFileManager defaultManager] fileExistsAtPath:[Paper autosavedPaperDirectory]]) 
	{
		Paper *paper = [[[Paper alloc] init] autorelease];
		[[NSFileManager defaultManager] copyItemAtPath:[Paper autosavedPaperDirectory]
												toPath:paper->localDirectory 
												 error:nil];
		NSData *xmlData = [NSData dataWithContentsOfFile:paper.localXMLPath];
		[paper parsePaperXML:xmlData];
		
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
	for (NSString *filename in filenames) {
		Paper *paper = [[[Paper alloc] init] autorelease];
		NSString *permanentDirectory = [[Paper savedPapersDirectory] stringByAppendingPathComponent:filename];
		[[NSFileManager defaultManager] copyItemAtPath:permanentDirectory 
												toPath:paper.localDirectory 
												 error:nil];
		[paper parsePaperXML:[NSData dataWithContentsOfFile:paper.localXMLPath]];
		[savedPapers addObject:paper];
	}
	return savedPapers;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
	return NO;
}

@end