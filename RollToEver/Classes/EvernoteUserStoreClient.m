//
//  EvernoteUserStoreClient.m
//  RollToEver
//
//  Created by fifnel on 2012/02/25.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteUserStoreClient.h"
#import "THTTPAsyncClient.h"
#import "TBinaryProtocol.h"
#import "UserStore.h"

#if 0
static NSString * const userStoreUri = @"https://sandbox.evernote.com/edam/user";
#else
static NSString * const userStoreUri = @"https://www.evernote.com/edam/user";
#endif

@interface EvernoteUserStoreClient ()

@property (strong, nonatomic, readwrite) EDAMUserStoreClient *userStoreClient;

@end

@implementation EvernoteUserStoreClient

@synthesize userStoreClient = _userStoreClient;


- (id)init
{
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        // クライアントの初期化
        NSURL *url = [[NSURL alloc] initWithString:userStoreUri];
        THTTPAsyncClient *httpClient = [[THTTPAsyncClient alloc] initWithURL:url];
        httpClient.delegate = delegate;
        TBinaryProtocol *protocol = [[TBinaryProtocol alloc] initWithTransport:httpClient];
        _userStoreClient = [[EDAMUserStoreClient alloc] initWithProtocol:protocol];
    }

    return self;
}

@end
