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
#import "AssetURLStorage.h"

@interface MyTest : GHAsyncTestCase
{
@private
    NSMutableArray *urls_;
    AssetURLStorage *assetUrlStorage_;
}

@end


@implementation MyTest

- (void)setUp {
    urls_ = [[NSMutableArray alloc] init];
    assetUrlStorage_ = [[AssetURLStorage alloc] init];
}

- (void)tearDown {
    assetUrlStorage_ = nil;
    urls_ = nil;
}

- (void)testStrings {
     [self prepare];
    
    NSString *string1 = @"a string";
    GHTestLog(@"I can log to the GHUnit test console: %@", string1);
    
    // Assert string1 is not NULL, with no custom error description
    GHAssertNotNULL((__bridge void*)string1, nil);
    
    // Assert equal objects, add custom error description
    NSString *string2 = @"a string";
    GHAssertEqualObjects(string1, string2, @"A custom error message. string1 should be equal to: %@.", string2);
}

@end