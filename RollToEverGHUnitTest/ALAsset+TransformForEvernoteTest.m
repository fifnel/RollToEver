//
//  ALAssetTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/06.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ALAssetTestUtility.h"
#import "ALAsset+TransformForEvernote.h"
 
@interface ALAssetTest : GHTestCase { }
@end
 
@implementation ALAssetTest
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
 
- (void)testJpegAssetTest {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"jpg"];
    
    GHAssertNotNil([asset filename], @"filename is nil");
    GHAssertEqualStrings([asset fileExtension], @"jpg", @"file extension is mismatch");
    GHAssertEquals([asset UTType], kUTTypeJPEG, @"UTType is mismatch");
    GHAssertEqualStrings([asset MIMEType], @"image/jpeg", @"MIMEType is mismatch");
    GHAssertGreaterThan([asset resizeRatio:100], 0.0f, @"resize ratio not greater than 0.0f");
    GHAssertGreaterThan([asset orientation], 0.0f, @"orientation not greater than 0.0f");
    GHAssertNotNil([asset transformForEvernote:100], @"transform is failure");
}

- (void)testPngAssetTest {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"png"];
    
    GHAssertNotNil([asset filename], @"filename is nil");
    GHAssertEqualStrings([asset fileExtension], @"png", @"file extension is mismatch");
    GHAssertEquals([asset UTType], kUTTypePNG, @"UTType is mismatch");
    GHAssertEqualStrings([asset MIMEType], @"image/png", @"MIMEType is mismatch");
    GHAssertGreaterThan([asset resizeRatio:100], 0.0f, @"resize ratio not greater than 0.0f");
    GHAssertGreaterThan([asset orientation], 0.0f, @"orientation not greater than 0.0f");
    GHAssertNotNil([asset transformForEvernote:100], @"transform is failure");
}

- (void)testGifAssetTest {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"gif"];
    
    GHAssertNotNil([asset filename], @"filename is nil");
    GHAssertEqualStrings([asset fileExtension], @"gif", @"file extension is mismatch");
    GHAssertEquals([asset UTType], kUTTypeGIF, @"UTType is mismatch");
    GHAssertEqualStrings([asset MIMEType], @"image/gif", @"MIMEType is mismatch");
    GHAssertGreaterThan([asset resizeRatio:100], 0.0f, @"resize ratio not greater than 0.0f");
    GHAssertGreaterThan([asset orientation], 0.0f, @"orientation not greater than 0.0f");
    GHAssertNotNil([asset transformForEvernote:100], @"transform is failure");
}

- (void)testTiffAssetTest {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"tif"];
    
    GHAssertNotNil([asset filename], @"filename is nil");
    GHAssertEqualStrings([asset fileExtension], @"tif", @"file extension is mismatch");
    GHAssertThrows([asset UTType], @"UTType is mismatch");
    GHAssertThrows([asset MIMEType], @"MIMEType is mismatch");
    /*
    GHAssertGreaterThan([asset resizeRatio:100], 0.0f, @"resize ratio not greater than 0.0f");
    GHAssertGreaterThan([asset orientation], 0.0f, @"orientation not greater than 0.0f");
    GHAssertThrows([asset transformForEvernote:100], @"transform is failure");
    */
}

- (void)testJp2AssetTest {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"jp2"];
    
    GHAssertNotNil([asset filename], @"filename is nil");
    GHAssertEqualStrings([asset fileExtension], @"jp2", @"file extension is mismatch");
    GHAssertThrows([asset UTType], @"UTType is mismatch");
    GHAssertThrows([asset MIMEType], @"MIMEType is mismatch");
    /*
    GHAssertGreaterThan([asset resizeRatio:100], 0.0f, @"resize ratio not greater than 0.0f");
    GHAssertGreaterThan([asset orientation], 0.0f, @"orientation not greater than 0.0f");
    GHAssertThrows([asset transformForEvernote:100], @"transform is failure");
    */
}


@end
