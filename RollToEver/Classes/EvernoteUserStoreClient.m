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

#if DEBUG==1
static NSString * const userStoreUri = @"https://sandbox.evernote.com/edam/user";
#else
static NSString * const userStoreUri = @"https://www.evernote.com/edam/user";
#endif

@interface EvernoteUserStoreClient ()

@property (assign, nonatomic, readwrite) EDAMUserStoreClient *userStoreClient;

@end

@implementation EvernoteUserStoreClient

@synthesize userStoreClient = userStoreClient_;


- (id)init
{
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        // クライアントの初期化
        NSURL *url = [[[NSURL alloc] initWithString:userStoreUri] autorelease];
        THTTPAsyncClient *httpClient = [[[THTTPAsyncClient alloc] initWithURL:url] autorelease];
        httpClient.delegate = delegate;
        TBinaryProtocol *protocol = [[[TBinaryProtocol alloc] initWithTransport:httpClient] autorelease];
        userStoreClient_ = [[EDAMUserStoreClient alloc] initWithProtocol:protocol];
    }
    return self;
}

- (void)dealloc
{
    [userStoreClient_ release];
    userStoreClient_ = nil;
    [super dealloc];
}

@end
