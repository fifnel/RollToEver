//
//  THTTPAsyncClient.h
//  RollToEver
//
//  Created by fifnel on 2012/02/17.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THTTPClient.h"

@interface THTTPAsyncClient : THTTPClient<NSURLConnectionDelegate>

@property(retain) id delegate;

- (void)cancel;

@end


@interface NSObject(THTTPAsyncClientDelegate)

// リクエスト送信前
- (NSURLRequest *)connection:(NSURLConnection *)connection
                      client:(THTTPAsyncClient *)client
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse;

// データ送信後
- (void)connection:(NSURLConnection *)connection
            client:(THTTPAsyncClient *)client
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

// レスポンス受信後
- (void)connection:(NSURLConnection *)connection
            client:(THTTPAsyncClient *)client
didReceiveResponse:(NSURLResponse *)response;

// データ受信後
- (void)connection:(NSURLConnection *)connection
            client:(THTTPAsyncClient *)client
    didReceiveData:(NSData *)data;

// リクエスト終了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
                            client:(THTTPAsyncClient *)client;

// 失敗
- (void)connection:(NSURLConnection *)connection
            client:(THTTPAsyncClient *)client
  didFailWithError:(NSError *)error;

@end