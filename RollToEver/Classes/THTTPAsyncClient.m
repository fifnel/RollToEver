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
NSMutableData *responseData_;
NSURLResponse *response_;
BOOL completed_;
NSError *requestError_;

@synthesize delegate = delegate_;


// リクエストをして結果を受信する（ブロックする）
- (void) flush
{
    [mRequest setHTTPBody: mRequestData]; // not sure if it copies the data
    
    if (responseData_ == nil) {
        responseData_ = [[NSMutableData alloc] init];
    }
    completed_ = NO;
    [responseData_ setLength:0];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:YES];
    while (!completed_) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    [urlConnection release];
    
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
} 

#pragma mark - NSURLConnection delegate

// リクエスト送信前
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
//    NSLog(@"willSendRequest");
    if ([delegate_ respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        [delegate_ connection:connection willSendRequest:request redirectResponse:redirectResponse];
    }
    return request;
}

// データ送信後
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//    NSLog(@"didSendBodyData:%d/%d/%d", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    if ([delegate_ respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [delegate_ connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

// レスポンス受信後
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    NSLog(@"didReceiveResponse");
    response_ = [response retain];
    if ([delegate_ respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [delegate_ connection:connection didReceiveResponse:response];
    }
    
}

// データ受信後
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    NSLog(@"didReceived");
    [responseData_ appendData:data];
    if ([delegate_ respondsToSelector:@selector(connection:didReceiveData:)]) {
        [delegate_ connection:connection didReceiveData:data];
    }
}

// リクエスト終了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([delegate_ respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [delegate_ connectionDidFinishLoading:connection];
    }
    completed_ = YES;
}

// 失敗
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if ([delegate_ respondsToSelector:@selector(connection:didFailWithError:)]) {
        [delegate_ connection:connection didFailWithError:error];
    }
    completed_ = YES;
    requestError_ = [error retain];
}

@end
