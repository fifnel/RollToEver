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
#import "AssetURLStorage.h"

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

- (void)testFilterdAssetURLList
{
    NSArray *list = [_assetsLibrary assetsURLList];
    
    AssetURLStorage *storage = [[AssetURLStorage alloc] init];
    
    [storage deleteAllURLs];
    
    NSArray *preFilterdList = [_assetsLibrary filteredAssetsURLList];
    
    __block NSString *excludeURL = [list objectAtIndex:0];
    [storage insertURL:excludeURL];
    
    NSArray *postFilterdList = [_assetsLibrary filteredAssetsURLList];

    GHAssertLessThan([postFilterdList count], [preFilterdList count], @"filter is not work");
}

@end