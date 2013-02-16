//
//  EDAMNoteStoreClient+WithDelegate.h
//  RollToEver
//
//  Created by fifnel on 2013/02/16.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "EDAMNoteStore.h"

@interface EDAMNoteStoreClient (WithDelegate)

// ノートストアクライアント取得
+ (EDAMNoteStoreClient *)noteStoreClientWithDelegate:(id)delegate UserAgent:userAgent;

@end
