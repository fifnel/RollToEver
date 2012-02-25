//
//  EvernoteNoteStoreClient+ALAsset.h
//  RollToEver
//
//  Created by fifnel on 2012/02/26.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteNoteStoreClient.h"
#import <AssetsLibrary/ALAsset.h>

@interface EvernoteNoteStoreClient (CreatePhotoNote)

- (void)createNoteFromAsset:(ALAsset *)asset NotebookGUID:(NSString *)notebookGUID;

@end
