//
//  THTTPAsyncClient.m
//  RollToEver
//
//  Created by fifnel on 2012/02/17.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "THTTPAsyncClient.h"
#import "TTransportException.h"

@implementation THTTPAsyncClient {
    BOOL _completed;

    __strong NSURLConnection *_urlConnection;
    __strong NSMutableData *_responseData;
    __strong NSURLResponse *_response;
    __strong NSError *_requestError;
}

// 送受信をキャンセルする
- (void)cancel
{
    [_urlConnection cancel];
    _completed = YES;
}


// リクエストをして結果を受信する（ブロックする）
- (void)flush
{
    [mRequest setHTTPBody:mRequestData]; // not sure if it copies the data

    _completed = NO;
    _responseData = [[NSMutableData alloc] init];
    _response = nil;

    _urlConnection = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:YES];
    while (!_completed) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    _urlConnection = nil;

    [mRequestData setLength:0];

    if (_responseData == nil) {
        @throw [TTransportException exceptionWithName:@"TTransportException"
                                               reason:@"Could not make HTTP request"
                                                error:_requestError];
    }
    if (![_response isKindOfClass:[NSHTTPURLResponse class]]) {
        @throw [TTransportException exceptionWithName:@"TTransportException"
                                               reason:[NSString stringWithFormat:@"Unexpected NSURLResponse type: %@",
                                                                                 NSStringFromClass([_response class])]];
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) _response;
    if ([httpResponse statusCode] != 200) {
        @throw [TTransportException exceptionWithName:@"TTransportException"
                                               reason:[NSString stringWithFormat:@"Bad response from HTTP server: %d",
                                                                                 [httpResponse statusCode]]];
    }

    mResponseData = _responseData;
    mResponseDataOffset = 0;
}

#pragma mark - NSURLConnection delegate

// リクエスト送信前
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
//    NSLog(@"willSendRequest");
    if ([_delegate respondsToSelector:@selector(connection:client:willSendRequest:redirectResponse:)]) {
        [_delegate connection:connection client:self willSendRequest:request redirectResponse:redirectResponse];
    }
    return request;
}

// データ送信後
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
//    NSLog(@"didSendBodyData:%d/%d/%d", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    if ([_delegate respondsToSelector:@selector(connection:client:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [_delegate connection:connection client:self didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

// レスポンス受信後
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSLog(@"didReceiveResponse");
    _response = response;
    if ([_delegate respondsToSelector:@selector(connection:client:didReceiveResponse:)]) {
        [_delegate connection:connection client:self didReceiveResponse:response];
    }

}

// データ受信後
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSLog(@"didReceived");
    [_responseData appendData:data];
    if ([_delegate respondsToSelector:@selector(connection:client:didReceiveData:)]) {
        [_delegate connection:connection client:self didReceiveData:data];
    }
}

// リクエスト終了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([_delegate respondsToSelector:@selector(connectionDidFinishLoading:client:)]) {
        [_delegate connectionDidFinishLoading:connection client:self];
    }
    _completed = YES;
}

// 失敗
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(connection:client:didFailWithError:)]) {
        [_delegate connection:connection client:self didFailWithError:error];
    }
    _completed = YES;
}

@end
