//
//  EvernoteNoteStoreClient.m
//  RollToEver
//
//  Created by fifnel on 2012/02/25.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "EvernoteNoteStoreClient.h"
#import "EvernoteAuthToken.h"
#import "THTTPAsyncClient.h"
#import "TBinaryProtocol.h"
#import "EvernoteNoteStore.h"
#import "id.h"

#ifdef FOR_DEVEL
static NSString * const noteStoreUriBase = @"https://sandbox.evernote.com/edam/note/"; 
#else
static NSString * const noteStoreUriBase = @"https://www.evernote.com/edam/note/"; 
#endif

@interface EvernoteNoteStoreClient ()

@property (strong, nonatomic, readwrite) EDAMNoteStoreClient *noteStoreClient;

@end


@implementation EvernoteNoteStoreClient

@synthesize noteStoreClient = _noteStoreClient;

- (id)init
{
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        // URL作成
        NSString *shardId = [EvernoteAuthToken sharedInstance].shardId;
        NSString *urlString = [NSString stringWithFormat:@"%@%@", noteStoreUriBase, shardId];
        NSURL *url = [[NSURL alloc] initWithString:urlString];
        
        // UserAgent作成
        UIDevice *device = [UIDevice currentDevice];
        NSString *userAgent = [NSString stringWithFormat:@"%@/%@;%@(%@)/%@",
                               APPLICATION_NAME,
                               APPLICATION_VERSION,
                               [device systemName],
                               [device model],
                               [device systemVersion]]; 

        // クライアントの初期化
        THTTPAsyncClient *httpClient = [[THTTPAsyncClient alloc] initWithURL:url userAgent:userAgent timeout:15000];
        httpClient.delegate = delegate;
        TBinaryProtocol *protocol = [[TBinaryProtocol alloc] initWithTransport:httpClient];
        _noteStoreClient = [[EDAMNoteStoreClient alloc] initWithProtocol:protocol];
    }
    
    return self;
}

@end
