//
//  EDAMNoteTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/06.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "ALAssetTestUtility.h"
#import "EDAMNote+CreateFromALAsset.h"

@interface EDAMNoteTest : GHTestCase { }
@end
 
@implementation EDAMNoteTest
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
 
- (void)testEDAMNoteFromJpg {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"jpg"];
    
    EDAMNote *note = [EDAMNote createFromALAsset:asset notebook:@"notebookgiud" photoSize:100];
    GHAssertNotNil(note, @"craeteFromALAsset is failure");
}

- (void)testEDAMNoteFromPng {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"png"];
    
    EDAMNote *note = [EDAMNote createFromALAsset:asset notebook:@"notebookgiud" photoSize:100];
    GHAssertNotNil(note, @"craeteFromALAsset is failure");
}

- (void)testEDAMNoteFromGif {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"gif"];
    
    EDAMNote *note = [EDAMNote createFromALAsset:asset notebook:@"notebookgiud" photoSize:100];
    GHAssertNotNil(note, @"craeteFromALAsset is failure");
}

- (void)testEDAMNoteFromTif {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"tif"];
    
    GHAssertThrows(
                   [EDAMNote createFromALAsset:asset notebook:@"notebookgiud" photoSize:100],
                   @"craeteFromALAsset is unknown result");
}

- (void)testEDAMNoteFromJp2 {
    ALAsset *asset = [_assetsUtility getFirstAssertByExtension:@"jp2"];
    
    GHAssertThrows(
                   [EDAMNote createFromALAsset:asset notebook:@"notebookgiud" photoSize:100],
                   @"craeteFromALAsset is unknown result");
}

@end