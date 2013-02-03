//
//  ALAssertTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/03.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "ALAssetTestUtility.h"
 
@interface ALAssertTest : GHTestCase
{
    __strong ALAssetTestUtility *_assetsUtility;
}
@end
 
@implementation ALAssertTest

//Method called before each tests
- (void) setUp
{
    _assetsUtility = [[ALAssetTestUtility alloc] init];
}

//Method called before after each tests
- (void) tearDown
{
    
} 
 
- (void)testGetJpeg {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"jpg"];
    GHAssertNotNil(asset, @"jpeg not found");
}

- (void)testGetGif {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"gif"];
    GHAssertNotNil(asset, @"gif not found");
}

- (void)testGetTiff {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"tif"];
    GHAssertNotNil(asset, @"tiff not found");
}

- (void)testSimpleFail {
	GHAssertTrue(NO, nil);
}
 
@end