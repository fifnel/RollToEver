//
//  EvernoteUploadTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/12.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "ALAsset+TransformForEvernote.h"
#import "EvernoteSession+Login.h"
#import "EDAMNoteStoreClient+WithDelegate.h"
#import "EDAMNote+CreateFromALAsset.h"
#import "MyGHUnitIOSAppDelegate.h"
#import "ALAssetTestUtility.h"
#import "AppDelegate.h"

@interface EvernoteUploadTest : GHTestCase { }
@end

@implementation EvernoteUploadTest
{
    __strong ALAssetTestUtility *_assetsUtility;
}

//Method called before each tests
- (void) setUp
{
    _assetsUtility = [[ALAssetTestUtility alloc] init];
}

//Method called before after each tests
- (void) tearDown
{
    
} 
 
- (void)testEvernoteUpload {
    MyGHUnitIOSAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    GHAssertTrue([EvernoteSession loginWithViewController:[delegate navigationController]], @"please single re-run test and authorize to Evernote.");
    
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"jpg"];
    GHAssertNotNil(asset, @"cannot got asset");
    
    EDAMNoteStoreClient *noteStoreClient = [EDAMNoteStoreClient noteStoreClientWithDelegate:nil UserAgent:[AppDelegate evernoteUserAgent]];
    EDAMNote *note = [EDAMNote createFromALAsset:asset notebook:nil photoSize:100];

    GHAssertNoThrow([noteStoreClient createNote:[[EvernoteSession sharedSession] authenticationToken] :note], @"evernote upload failure");
}

@end