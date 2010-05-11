//
//  Paper+Saving.h
//  Reader
//
//  Created by Tom Brow on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Paper.h"

@interface SavedPapersManager : NSObject {
}

- (NSSet *) savedPapers;

@end


@interface Paper(Saving)

+ (SavedPapersManager *) savedPapersManager;
- (void) save;
- (void) unsave;
- (BOOL) saved;
- (void) restore;
- (void) autosave;
+ (Paper *) autosavedPaper;

@end
