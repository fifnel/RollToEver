//
//  EvernoteSession+LoginTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/11.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "EvernoteSession+Login.h"
#import "MyGHUnitIOSAppDelegate.h"

@interface EvernoteSession_LoginTest : GHTestCase { }
@end
 
@implementation EvernoteSession_LoginTest

//Method called before each tests
- (void) setUp
{
    
}

//Method called before after each tests
- (void) tearDown
{
    
} 

- (void)testLoginIsSuccess {
    MyGHUnitIOSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    GHAssertTrue([EvernoteSession loginWithViewController:[delegate navigationController]], @"please single re-run test and authorize to Evernote.");
}
 
@end