//
//  EDAMNoteStoreClient+WithDelegate.m
//  RollToEver
//
//  Created by fifnel on 2013/02/16.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "EDAMNoteStoreClient+WithDelegate.h"
#import "EvernoteSession.h"
#import "Thrift.h"
#import "THTTPAsyncClient.h"

@implementation EDAMNoteStoreClient (WithDelegate)

+ (EDAMNoteStoreClient *)noteStoreClientWithDelegate:(id)delegate UserAgent:userAgent
{
    NSURL *url = [NSURL URLWithString:[[EvernoteSession sharedSession] noteStoreUrl]];
    THTTPAsyncClient *httpClient = [[THTTPAsyncClient alloc] initWithURL:url userAgent:userAgent timeout:15000];
    httpClient.delegate = delegate;
    TBinaryProtocol *protocol = [[TBinaryProtocol alloc] initWithTransport:httpClient];
    return [[EDAMNoteStoreClient alloc] initWithProtocol:protocol];
}

@end
