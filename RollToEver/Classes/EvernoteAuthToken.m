//
//  EvernoteAuthToken.m
//  RollToEver
//
//  Created by fifnel on 2012/02/24.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteAuthToken.h"

#import "EvernoteUserStoreClient.h"
#import "THTTPAsyncClient.h"
#import "TBinaryProtocol.h"
#import "UserStore.h"
#import "NoteStore.h"
#import "Errors.h"
#import "TTransportException.h"

@interface EvernoteAuthToken()

@property (retain, nonatomic, readwrite) NSString *authToken;
@property (retain, nonatomic, readwrite) NSString *shardId;
@property (retain, nonatomic, readwrite) EDAMUser *edamUser;

@property (assign, nonatomic, readwrite) NSInteger edamErrorCode;
@property (assign, nonatomic, readwrite) BOOL edamErrorCodeIsSet;
@property (assign, nonatomic, readwrite) BOOL transportError;

@end

static EvernoteAuthToken *sharedEvernoteAuthTokenInstance_ = nil;

@implementation EvernoteAuthToken

@synthesize authToken = authToken_;
@synthesize shardId = shardId_;
@synthesize edamUser = edamUser_;
@synthesize edamErrorCode = edamErrorCode_;
@synthesize edamErrorCodeIsSet = edamErrorCodeIsSet_;
@synthesize transportError = transportError_;

+(EvernoteAuthToken *)sharedInstance {
    @synchronized(self) {
        if (sharedEvernoteAuthTokenInstance_ == nil) {
            [[self alloc] init]; // ここでは代入していない
        }
    }
    return sharedEvernoteAuthTokenInstance_;
}

+(id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedEvernoteAuthTokenInstance_ == nil) {
            sharedEvernoteAuthTokenInstance_ = [super allocWithZone:zone];
            return sharedEvernoteAuthTokenInstance_;  // 最初の割り当てで代入し、返す
        }
    }
    return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (oneway void)release {
    // 何もしない
}

- (id)autorelease {
    return self;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        self.authToken = nil;
        self.edamUser = nil;
        self.shardId = nil;
        
        self.edamErrorCode = 0;
        self.edamErrorCodeIsSet = NO;
        self.transportError = NO;
    }
    return self;
}

- (bool)connectWithUserId:(NSString *)userId
                 Password:(NSString *)password
               ClientName:(NSString *)clientName
              ConsumerKey:(NSString *)consumerKey
           ConsumerSecret:(NSString *)consumerSecret {
    
    self.authToken = nil;
    self.edamUser = nil;
    self.shardId = nil;
    self.edamErrorCode = 0;
    self.edamErrorCodeIsSet = NO;
    self.transportError = NO;

    EvernoteUserStoreClient *userStoreClient = [[EvernoteUserStoreClient alloc] init];

    
    EDAMAuthenticationResult *authResult = nil;
    @try {
        bool versionOk = [[userStoreClient userStoreClient]
                          checkVersion:clientName
                          :[EDAMUserStoreConstants EDAM_VERSION_MAJOR]
                          :[EDAMUserStoreConstants EDAM_VERSION_MINOR]];
        if (!versionOk) {
            return false;
        }

        authResult = [[userStoreClient userStoreClient] authenticate:userId
                                                                    :password
                                                                    :consumerKey
                                                                    :consumerSecret];
    }
    @catch (EDAMUserException *exception) {
        self.edamErrorCodeIsSet = exception.errorCodeIsSet;
        self.edamErrorCode = exception.errorCode;
        NSLog(@"errorcode = %d", self.edamErrorCode);
        return false;
    }
    @catch (TTransportException *exception) {
        self.transportError = YES;
        NSLog(@"transport error");
        return false;
    }
    if (authResult == nil ||
        ![authResult authenticationTokenIsSet] ||
        ![authResult userIsSet] ) {
        return false;
    }
    EDAMUser *user = [authResult user];
    if (![user shardIdIsSet]) {
        
    }
    if (![authResult authenticationTokenIsSet]) {
        return false;
    }
    self.authToken = [authResult authenticationToken];
    self.edamUser = user;
    self.shardId = [user shardId];
    
    return true;
}

@end
