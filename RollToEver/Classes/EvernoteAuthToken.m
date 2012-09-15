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
#import "EvernoteUserStore.h"
#import "EvernoteNoteStore.h"
#import "TTransportException.h"
#import "GCDSingleton.h"

@interface EvernoteAuthToken ()

@property (strong, nonatomic, readwrite) NSString *authToken;
@property (strong, nonatomic, readwrite) NSString *shardId;
@property (strong, nonatomic, readwrite) EDAMUser *edamUser;

@property (assign, nonatomic, readwrite) NSInteger edamErrorCode;
@property (assign, nonatomic, readwrite) BOOL edamErrorCodeIsSet;
@property (assign, nonatomic, readwrite) BOOL transportError;

@end

@implementation EvernoteAuthToken

SINGLETON_GCD(EvernoteAuthToken);

@synthesize authToken     = _authToken;
@synthesize shardId       = _shardId;
@synthesize edamUser      = _edamUser;

@synthesize edamErrorCode      = _edamErrorCode;
@synthesize edamErrorCodeIsSet = _edamErrorCodeIsSet;
@synthesize transportError     = _transportError;

- (id)init
{
    self = [super init];
    if (self != nil) {
        _edamErrorCode = 0;
        _edamErrorCodeIsSet = NO;
        _transportError = NO;
    }
    return self;
}

- (void)connectWithUserId:(NSString *)userId
                 Password:(NSString *)password
               ClientName:(NSString *)clientName
              ConsumerKey:(NSString *)consumerKey
           ConsumerSecret:(NSString *)consumerSecret
{
    self.authToken  = nil;
    self.edamUser   = nil;
    self.shardId    = nil;
    self.edamErrorCode      = 0;
    self.edamErrorCodeIsSet = NO;
    self.transportError     = NO;

    EvernoteUserStoreClient *userStoreClient = [[EvernoteUserStoreClient alloc] init];
    
    EDAMAuthenticationResult *authResult = nil;
    @try {
        bool versionOk = [[userStoreClient userStoreClient]
                          checkVersion:clientName
                          :[EDAMUserStoreConstants EDAM_VERSION_MAJOR]
                          :[EDAMUserStoreConstants EDAM_VERSION_MINOR]];
        if (!versionOk) {
            EDAMUserException *e = [[EDAMUserException alloc] initWithErrorCode:EDAMErrorCode_UNKNOWN parameter:nil];
            @throw e;
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
        @throw exception;
    }
    @catch (NSException *exception) {
        self.transportError = YES;
        NSLog(@"EvernoteAuthToken exception:%@", [exception reason]);
        @throw exception;
    }
    if (authResult == nil ||
        ![authResult authenticationTokenIsSet] ||
        ![authResult userIsSet] ) {
        EDAMUserException *e = [[EDAMUserException alloc] initWithErrorCode:EDAMErrorCode_UNKNOWN parameter:nil];
        @throw e;
    }
    EDAMUser *user = [authResult user];
    if (![user shardIdIsSet]) {
        
    }
    if (![authResult authenticationTokenIsSet]) {
        EDAMUserException *e = [[EDAMUserException alloc] initWithErrorCode:EDAMErrorCode_UNKNOWN parameter:nil];
        @throw e;
    }
    self.authToken = [authResult authenticationToken];
    self.edamUser = user;
    self.shardId = [user shardId];
}

@end
