//
//  EvernoteNoteStoreClient.h
//  RollToEver
//
//  Created by fifnel on 2012/02/25.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteStore.h"

@interface EvernoteNoteStoreClient : NSObject

@property (retain, readonly) EDAMNoteStoreClient *noteStoreClient;

- (id) initWithDelegate:(id)delegate;

@end
