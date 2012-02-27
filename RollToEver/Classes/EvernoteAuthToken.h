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

@property (assign, nonatomic, readonly) NSInteger edamErrorCode;
@property (assign, nonatomic, readonly) BOOL edamErrorCodeIsSet;
@property (assign, nonatomic, readonly) BOOL transportError;

/*
 EDAMErrorCode_UNKNOWN = 1,
 EDAMErrorCode_BAD_DATA_FORMAT = 2,
 EDAMErrorCode_PERMISSION_DENIED = 3,
 EDAMErrorCode_INTERNAL_ERROR = 4,
 EDAMErrorCode_DATA_REQUIRED = 5,
 EDAMErrorCode_LIMIT_REACHED = 6,
 EDAMErrorCode_QUOTA_REACHED = 7,
 EDAMErrorCode_INVALID_AUTH = 8,
 EDAMErrorCode_AUTH_EXPIRED = 9,
 EDAMErrorCode_DATA_CONFLICT = 10,
 EDAMErrorCode_ENML_VALIDATION = 11,
 EDAMErrorCode_SHARD_UNAVAILABLE = 12
*/

@end
