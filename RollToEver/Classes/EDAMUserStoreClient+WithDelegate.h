//
//  EDAMUserStoreClient+WithDelegate.h
//  RollToEver
//
//  Created by fifnel on 2013/02/16.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "EDAMUserStore.h"

@interface EDAMUserStoreClient (WithDelegate)

// ユーザーストアクライアント取得
+ (EDAMUserStoreClient *)userStoreClientWithDelegate:(id)delegate UserAgent:userAgent;

@end
