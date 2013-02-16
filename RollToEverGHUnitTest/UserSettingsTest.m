//
//  UserSettingsTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/16.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "UserSettings.h"
 
@interface UserSettingsTest : GHTestCase { }
@end
 
@implementation UserSettingsTest

//Method called before each tests
- (void) setUp
{
    
}

//Method called before after each tests
- (void) tearDown
{
    
} 
 
- (void)testSettingReadWrite {
    
    NSString *version = @"1.0.0";
    [[UserSettings sharedInstance] setVersion:version];
    GHAssertEqualStrings([[UserSettings sharedInstance] version], version, @"version is not saved");

    NSString *isFirstTime = @"true";
    [[UserSettings sharedInstance] setIsFirstTime:isFirstTime];
    GHAssertEqualStrings([[UserSettings sharedInstance] isFirstTime], isFirstTime, @"isFirstTime is not saved");
    
    NSString *evernoteNotebookName = @"notebookname";
    [[UserSettings sharedInstance] setEvernoteNotebookName:evernoteNotebookName];
    GHAssertEqualStrings([[UserSettings sharedInstance] evernoteNotebookName], evernoteNotebookName, @"evernoteNotebookName is not saved");
    
    NSString *evernoteNotebookGUID = @"notebookguid";
    [[UserSettings sharedInstance] setEvernoteNotebookGUID:evernoteNotebookGUID];
    GHAssertEqualStrings([[UserSettings sharedInstance] evernoteNotebookGUID], evernoteNotebookGUID, @"evernoteNotebookGUID is not saved");
    
    NSInteger photoSizeIndex = 1;
    [[UserSettings sharedInstance] setPhotoSizeIndex:photoSizeIndex];
    GHAssertEquals([[UserSettings sharedInstance] photoSizeIndex], photoSizeIndex, @"photoSizeIndex is not saved");
    GHAssertEquals([[UserSettings sharedInstance] photoSize], 1224 * 1632, @"photoSize is unmatched");
    
    BOOL killIdleSleepFlag = YES;
    [[UserSettings sharedInstance] setKillIdleSleepFlag:killIdleSleepFlag];
    GHAssertEquals([[UserSettings sharedInstance] killIdleSleepFlag], killIdleSleepFlag, @"killIdleSleepFlag is not saved");
}
 
@end