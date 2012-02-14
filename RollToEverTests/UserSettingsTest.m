//
//  UserSettingsTest.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UserSettingsTest.h"

#import "UserSettings.h"

@implementation UserSettingsTest

// All code under test must be linked into the Unit Test bundle
- (void)testMath
{
    [[UserSettings alloc] init];
    STAssertTrue((1 + 1) == 2, @"Compiler isn't feeling well today :-(");
}

- (void)testBasic {
    NSString *orig = [UserSettings sharedInstance].evernoteUserId;
    
    NSString *user = [UserSettings sharedInstance].evernoteUserId;
    NSLog(@"user=%@", user);
    [UserSettings sharedInstance].evernoteUserId = @"fooooo";
    NSString *user2 = [UserSettings sharedInstance].evernoteUserId;
    NSLog(@"user2=%@", user2);

    [UserSettings sharedInstance].evernoteUserId = orig;
    
    NSString *version_orig = [UserSettings sharedInstance].version;
    [UserSettings sharedInstance].version = @"hogever";
    NSString *version_new = [UserSettings sharedInstance].version;
    NSLog(@"ver orig=%@ new=%@", version_orig, version_new);
    [UserSettings sharedInstance].version = version_orig;



    NSString *first_orig = [UserSettings sharedInstance].isFirstTime;
    [UserSettings sharedInstance].isFirstTime = @"hogefirst";
    NSString *first_new = [UserSettings sharedInstance].isFirstTime;
    NSLog(@"first orig=%@ new=%@", first_orig, first_new);
    [UserSettings sharedInstance].isFirstTime = first_orig;
}

@end
