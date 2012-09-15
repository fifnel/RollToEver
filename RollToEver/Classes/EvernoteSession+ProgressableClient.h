//
//  EvernoteSession+ProgressableClient.h
//  RollToEver
//
//  Created by fifnel on 2012/09/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteSession.h"

@interface EvernoteSession (ProgressableClient)

- (EDAMNoteStoreClient *)noteStoreWithDelegate:(id)delegate;

- (EDAMUserStoreClient *)userStoreWithDelegate:(id)delegate;

@end
