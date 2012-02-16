//
//  AsiHttpTest.m
//  RollToEver
//
//  Created by fifnel on 2012/02/16.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GHUnitIOS/GHUnit.h> 
#import "ASIHTTPRequest.h"

@interface AsiHttpTest : GHAsyncTestCase

@end


@implementation AsiHttpTest

- (void)testHttpRequest {
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.yahoo.co.jp/"];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    [request setUploadProgressDelegate:self];
    [request startSynchronous];
    NSLog(@"aaaaaaaaaaaaaaaaa");
}

#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"finished");
    NSLog(@"%@", [request responseString]);
}
- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data {
    NSLog(@"recv:%d---------", [data length]);
}

- (void)incrementUploadSizeBy:(long long)length {
    NSLog(@"upload progress:%lld", length);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"%@", error);
    // 通信ができなかったときの処理
}

@end
