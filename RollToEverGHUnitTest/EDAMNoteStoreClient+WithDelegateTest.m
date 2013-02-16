//
//  EDAMNoteStoreClient+WithDelegateTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/17.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "EDAMNoteStoreClient+WithDelegate.h"
 
@interface EDAMNoteStoreClient_WithDelegateTest : GHTestCase { }
@end
 
@implementation EDAMNoteStoreClient_WithDelegateTest

//Method called before each tests
- (void) setUp
{
    
}

//Method called before after each tests
- (void) tearDown
{
    
} 
 
- (void)testNoteStoreClient {
    EDAMNoteStoreClient *client = [EDAMNoteStoreClient noteStoreClientWithDelegate:nil UserAgent:@"dummy-ua"];
    GHAssertNotNil(client, @"note store client allocate failure");
}

@end