//
//  THTTPAsyncClient.m
//  RollToEver
//
//  Created by fifnel on 2012/02/17.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "THTTPAsyncClient.h"
#import "TTransportException.h"

@implementation THTTPAsyncClient

// instance valiables
NSURLConnection *urlConnection_;
NSMutableData *responseData_;
NSURLResponse *response_;
BOOL completed_;
NSError *requestError_;

@synthesize delegate = delegate_;

// 送受信をキャンセルする
- (void)cancel
{
    [urlConnection_ cancel];
    completed_ = YES;
}


// リクエストをして結果を受信する（ブロックする）
- (void) flush
{
    [mRequest setHTTPBody: mRequestData]; // not sure if it copies the data
    
    completed_ = NO;
    responseData_ = [[NSMutableData alloc] init];
    response_ = nil;

    urlConnection_ = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:YES];
    while (!completed_) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    [urlConnection_ release];
    urlConnection_ = nil;
    
    [mRequestData setLength: 0];
    
    if (responseData_ == nil) {
        @throw [TTransportException exceptionWithName: @"TTransportException"
                                               reason: @"Could not make HTTP request"
                                                error: requestError_];
    }
    if (![response_ isKindOfClass: [NSHTTPURLResponse class]]) {
        @throw [TTransportException exceptionWithName: @"TTransportException"
                                               reason: [NSString stringWithFormat: @"Unexpected NSURLResponse type: %@",
                                                        NSStringFromClass([response_ class])]];
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response_;
    if ([httpResponse statusCode] != 200) {
        @throw [TTransportException exceptionWithName: @"TTransportException"
                                               reason: [NSString stringWithFormat: @"Bad response from HTTP server: %d",
                                                        [httpResponse statusCode]]];
    }

    [mResponseData release];
    mResponseData = [responseData_ retain];
    mResponseDataOffset = 0;

    [response_ release];
    [responseData_ release];
} 

#pragma mark - NSURLConnection delegate

// リクエスト送信前
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
//    NSLog(@"willSendRequest");
    if ([delegate_ respondsToSelector:@selector(connection:client:willSendRequest:redirectResponse:)]) {
        [delegate_ connection:connection client:self willSendRequest:request redirectResponse:redirectResponse];
    }
    return request;
}

// データ送信後
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
//    NSLog(@"didSendBodyData:%d/%d/%d", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    if ([delegate_ respondsToSelector:@selector(connection:client:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [delegate_ connection:connection client:self didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

// レスポンス受信後
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSLog(@"didReceiveResponse");
    response_ = [response retain];
    if ([delegate_ respondsToSelector:@selector(connection:client:didReceiveResponse:)]) {
        [delegate_ connection:connection client:self didReceiveResponse:response];
    }
    
}

// データ受信後
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSLog(@"didReceived");
    [responseData_ appendData:data];
    if ([delegate_ respondsToSelector:@selector(connection:client:didReceiveData:)]) {
        [delegate_ connection:connection client:self didReceiveData:data];
    }
}

// リクエスト終了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([delegate_ respondsToSelector:@selector(connectionDidFinishLoading:client:)]) {
        [delegate_ connectionDidFinishLoading:connection client:self];
    }
    completed_ = YES;
}

// 失敗
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([delegate_ respondsToSelector:@selector(connection:client:didFailWithError:)]) {
        [delegate_ connection:connection client:self didFailWithError:error];
    }
    completed_ = YES;
//    requestError_ = [error retain];
}

@end
