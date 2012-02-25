//
//  EvernoteAuthToken.h
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserStore.h"

@interface EvernoteAuthToken : NSObject

+ (EvernoteAuthToken *)sharedInstance;

- (bool)connectWithUserName:(NSString *)userName
                   Password:(NSString *)password
                 ClientName:(NSString *)clientName
                ConsumerKey:(NSString *)consumerKey
             ConsumerSecret:(NSString *)consumerSecret;

@property (retain, nonatomic, readonly) NSString *authToken;
@property (retain, nonatomic, readonly) NSString *shardId;
@property (retain, nonatomic, readonly) EDAMUser *edamUser;

@end
