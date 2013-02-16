//
//  EvernoteSession+ProgressableClient.h
//  RollToEver
//
//  Created by fifnel on 2012/09/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteSession.h"

@interface EvernoteSession (ProgressableClient)

// ノートストアクライアント取得
- (EDAMNoteStoreClient *)noteStoreClientWithDelegate:(id)delegate UserAgent:userAgent;

// ユーザーストアクライアント取得
- (EDAMUserStoreClient *)userStoreClientWithDelegate:(id)delegate UserAgent:userAgent;

@end
