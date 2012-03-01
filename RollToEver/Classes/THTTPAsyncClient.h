//
//  THTTPAsyncClient.h
//  RollToEver
//
//  Created by fifnel on 2012/02/17.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THTTPClient.h"

@interface THTTPAsyncClient : THTTPClient

@property(retain) id delegate;

@end
