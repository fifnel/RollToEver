//
//  EvernoteAuthToken.h
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EvernoteUserStore.h"

@interface EvernoteAuthToken : NSObject

+ (EvernoteAuthToken *)sharedInstance;

- (void)connectWithUserId:(NSString *)userId
                 Password:(NSString *)password
               ClientName:(NSString *)clientName
              ConsumerKey:(NSString *)consumerKey
           ConsumerSecret:(NSString *)consumerSecret;

@property (strong, nonatomic, readonly) NSString *authToken;
@property (strong, nonatomic, readonly) NSString *shardId;
@property (strong, nonatomic, readonly) EDAMUser *edamUser;

@property (assign, nonatomic, readonly) NSInteger edamErrorCode;
@property (assign, nonatomic, readonly) BOOL edamErrorCodeIsSet;
@property (assign, nonatomic, readonly) BOOL transportError;

@end
