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
 
- (void)testLoginIsFailure {
    GHAssertFalse([EvernoteSession loginWithViewController:nil], @"unknown status");
}
 
@end