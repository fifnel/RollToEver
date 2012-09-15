//
//  RollToEverTests.m
//  RollToEverTests
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "RollToEverTests.h"
#import "EvernoteAuthToken.h"
#import "UserSettings.h"
#import "id.h"

@implementation RollToEverTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testAuthToken
{
    /*
    bool ret = [[EvernoteAuthToken sharedInstance] connectWithUserId:[UserSettings sharedInstance].evernoteUserId
                                                            Password:[UserSettings sharedInstance].evernotePassword
                                                          ClientName:APPLICATION_NAME
                                                         ConsumerKey:CONSUMER_KEY
                                                      ConsumerSecret:CONSUMER_SECRET];
    STAssertTrue(ret, @"EvernoteAuthToken connect failure");
//    STFail(@"Unit tests are not implemented yet in RollToEverTests");
     */
}

@end
