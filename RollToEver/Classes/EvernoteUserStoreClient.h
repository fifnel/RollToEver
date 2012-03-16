//
//  EvernoteUserStoreClient.h
//  RollToEver
//
//  Created by fifnel on 2012/02/25.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserStore.h"

@interface EvernoteUserStoreClient : NSObject

@property (strong, nonatomic, readonly) EDAMUserStoreClient *userStoreClient;

- (id) initWithDelegate:(id)delegate;

@end
