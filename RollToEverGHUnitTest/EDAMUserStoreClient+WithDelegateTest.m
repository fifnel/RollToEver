//
//  EDAMUserStoreClient+WithDelegateTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/17.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "EDAMUserStoreClient+WithDelegate.h"

@interface EDAMUserStoreClient_WithDelegateTest : GHTestCase { }
@end
 
@implementation EDAMUserStoreClient_WithDelegateTest

//Method called before each tests
- (void) setUp
{
    
}

//Method called before after each tests
- (void) tearDown
{
    
} 
 
- (void)testUserStoreClient {
    EDAMUserStoreClient *client = [EDAMUserStoreClient userStoreClientWithDelegate:nil UserAgent:@"dummy-ua"];
    GHAssertNotNil(client, @"user store client allocate failure");
}

@end