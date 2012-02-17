//
//  THTTPAsyncClient.m
//  RollToEver
//
//  Created by fifnel on 2012/02/17.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "THTTPAsyncClient.h"
#import "TTransportException.h"

@interface THTTPAsyncClient()
{
@private
    NSURLConnection *urlConnection_;
    NSMutableData *responseData_;
    NSURLResponse *response_;
    BOOL completed_;
    NSError *requestError_;
}
@end

@implementation THTTPAsyncClient

@synthesize delegate = delegate_;

- (void) flush
{
    [mRequest setHTTPBody: mRequestData]; // not sure if it copies the data
    
    if (responseData_ == nil) {
        responseData_ = [[NSMutableData alloc] init];
    }
    completed_ = NO;
    [responseData_ setLength:0];
    urlConnection_ = [[NSURLConnection alloc] initWithRequest:mRequest delegate:self startImmediately:YES];
    
    while (!completed_) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    response_ = [response retain];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"didReceived");
    [responseData_ appendData:data];
}


- (void)testRemainMainThread:(NSDictionary *)params {
    NSNumber *remain = [params valueForKey:@"remain"];
    NSNumber *sended = [params valueForKey:@"sended"];
    NSNumber *total = [params valueForKey:@"total"];
    
    [delegate_ testRemainAsync:[remain intValue] sended:[sended intValue] total:[total intValue]];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    NSLog(@"didSendBodyData:%d/%d/%d", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    
    if ([delegate_ respondsToSelector:@selector(testRemainAsync:sended:total:)]) {
        /*
        NSNumber *remain = [NSNumber numberWithInt:bytesWritten];
        NSNumber *sended = [NSNumber numberWithInt:totalBytesWritten];
        NSNumber *total = [NSNumber numberWithInt:totalBytesExpectedToWrite];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                               remain, @"remain",
                               sended, @"sended",
                               total, @"total",
                               nil];
        [self performSelectorOnMainThread:@selector(testRemainMainThread:) withObject:params waitUntilDone:YES];
         */
        [delegate_ testRemainAsync:bytesWritten sended:totalBytesWritten total:totalBytesExpectedToWrite];
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    NSLog(@"willSendRequest");
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    completed_ = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    completed_ = YES;
    requestError_ = [error retain];
}

@end
