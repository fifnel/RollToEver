//
//  ALAssetsLibrary+FilteredListTest.m
//  RollToEver
//
//  Created by fifnel on 2013/02/10.
//  Copyright 2013年 fifnel. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
//#import <OCMock/OCMock.h>
#import "ALAssetsLibrary+FilteredList.h"
#import "ALAssetsLibrary+BlockingUtility.h"
#import "UploadedURLModel.h"

@interface ALAssetsLibrary_FilteredListTest : GHTestCase { }
@end
 
@implementation ALAssetsLibrary_FilteredListTest
{
    __strong ALAssetsLibrary *_assetsLibrary;
}

//Method called before each tests
- (void) setUp
{
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
}

//Method called before after each tests
- (void) tearDown
{
    
} 

- (void)testFilteredAssetURLList
{
    NSArray *list = [_assetsLibrary assetsURLList];
    
    UploadedURLModel *storage = [[UploadedURLModel alloc] init];
    
    [storage deleteAllUploadedURL];
    
    NSArray *preFilteredList = [_assetsLibrary filteredAssetsURLList];
    
    __block NSString *excludeURL = [list objectAtIndex:0];
    [storage saveUploadedURL:excludeURL];
    
    NSArray *postFilteredList = [_assetsLibrary filteredAssetsURLList];

    GHAssertLessThan([postFilteredList count], [preFilteredList count], @"filter is not work");
}

@end