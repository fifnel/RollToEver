//
//  MyTest.m
//  MyTestable
//
//  Created by Gabriel Handford on 7/16/11.
//  Copyright 2011 rel.me. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h> 
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "AssetsEnumerator.h"
#import "AssetURLStorage.h"
#import "AllAssetsURLRegister.h"

@interface MyTest : GHAsyncTestCase
{
@private
    AssetsEnumerator *enumerator_;
    NSMutableArray *urls_;
    AssetURLStorage *assetUrlStorage_;
    AllAssetsURLRegister *allregister_;
}

@end


@implementation MyTest

- (void)setUp {
    enumerator_ = [[AssetsEnumerator alloc] init];
    enumerator_.delegate = self;
    urls_ = [[NSMutableArray alloc] init];
    assetUrlStorage_ = [[AssetURLStorage alloc] init];
    allregister_ = [[AllAssetsURLRegister alloc] init];
    allregister_.delegate = self;
}

- (void)tearDown {
    [assetUrlStorage_ release];
    [urls_ release];
    [enumerator_ release];
}

- (void)testStrings {
     [self prepare];
    
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    
    // Assert string1 is not NULL, with no custom error description
    GHAssertNotNULL(string1, nil);
    
    // Assert equal objects, add custom error description
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
}

- (void)testAssetsEnumeration {
    [self prepare];

    [enumerator_ startEnumeration];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)AssetsEnumerationStart:(NSInteger)count {
    [urls_ release];
    urls_ = [[NSMutableArray alloc] init];
}

- (void)AssetsEnumerationEnd {
    // ここになんか処理書く
    NSString *msg = [NSString stringWithFormat:@"%d枚のアップロード対象画像が見つかりました。", [urls_ count]];
    UIAlertView *alertDone = [[UIAlertView alloc] initWithTitle:@"RoolToEver" message:msg delegate:self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [alertDone show];
    [alertDone release];
    NSLog(@"enumeration finish  count=%d", [urls_ count]);
    
    @try {
//        GHAssertFalse(YES, @"hoge");
        [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testAssetsEnumeration)];
    }
    @catch (NSException *exception) {
        [self notify:kGHUnitWaitStatusFailure forSelector:@selector(testAssetsEnumeration)];
    }
}

- (void)AssetsEnumerationFind:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop{
    if (asset == nil) {
        return;
    }
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    if (![assetUrlStorage_ isExistURL:[rep.url absoluteString]]) {
        NSLog(@"add url:%@", [rep.url absoluteString]);
        [urls_ addObject:rep.url];
    } else {
        NSLog(@"skip url:%@", [rep.url absoluteString]);
    }
    
//    *stop = YES;
}

- (void)AssetsEnumerationFailure:(NSError *)error {
}

- (void)testAllRegister {
    [allregister_ start];
//    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:10.0];
}

- (void)AllAssetsURLRegisterDidFinish:(BOOL)succeeded {
    GHAssertTrue(succeeded, @"AllAssetsURLRegisterDidFinish failure");
//    [self notify:kGHUnitWaitStatusSuccess forSelector:@selector(testAllRegister)];
}

@end