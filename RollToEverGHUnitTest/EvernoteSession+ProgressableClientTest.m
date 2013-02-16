//
//  EvernoteSession+ProgressableClientTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/11.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "EvernoteSession+ProgressableClient.h"
 
@interface EvernoteSession_ProgressableClientTest : GHTestCase { }
@end
 
@implementation EvernoteSession_ProgressableClientTest

//Method called before each tests
- (void) setUp
{
    
}

//Method called before after each tests
- (void) tearDown
{
    
}

- (void)testNoteStoreClient {
    EvernoteSession *session = [EvernoteSession sharedSession];
    EDAMNoteStoreClient *client = [session noteStoreClientWithDelegate:nil UserAgent:@"dummy-ua"];
    GHAssertNotNil(client, @"note store client allocate failure");
}
 
- (void)testUserStoreClient {
    EvernoteSession *session = [EvernoteSession sharedSession];
    EDAMUserStoreClient *client = [session userStoreClientWithDelegate:nil UserAgent:@"dummy-ua"];
    GHAssertNotNil(client, @"user store client allocate failure");
} 
 
@end