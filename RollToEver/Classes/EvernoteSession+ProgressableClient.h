//
//  EvernoteSession+ProgressableClient.h
//  RollToEver
//
//  Created by fifnel on 2012/09/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteSession.h"

@interface EvernoteSession (ProgressableClient)

// ユーザーエージェント文字列の取得
// TODO もっと汎用的に使える場所におきたい。AppDelegateとか
+ (NSString *)userAgent;

// ノートストアクライアント取得
- (EDAMNoteStoreClient *)noteStoreClientWithDelegate:(id)delegate;

// ユーザーストアクライアント取得
- (EDAMUserStoreClient *)userStoreClientWithDelegate:(id)delegate;

@end
