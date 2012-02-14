//
//  AssetsEnumeratorTest.m
//  RollToEver
//
//  Created by fifnel on 2012/02/11.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AssetsEnumeratorTest.h"

#import "AssetsEnumerator.h"

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetsFilter.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@implementation AssetsEnumeratorTest

- (void)AssetsEnumerationStart:(NSInteger)count {
    NSLog(@"AssetsEnumerationStart:%d", count);
}

- (void)AssetsEnumerationEnd {
    NSLog(@"AssetsEnumerationEnd");
}

- (void)AssetsEnumerationFind:(ALAsset *)asset index:(NSInteger)index {
    NSString *url = [asset valueForProperty:ALAssetPropertyURLs];
    NSString *date = [asset valueForProperty:ALAssetPropertyDate];
    NSLog(@"AssetsEnumerationFind:%@ %@", url, date);
}

- (void)AssetsEnumerationFailure:(NSError *)error {
    NSLog(@"AssetsEnumerationFailure:%@", error);
}


- (void)testAssetsEnumerator
{
    AssetsEnumerator *ae = [[AssetsEnumerator alloc] init];
    ae.delegate = self;
    [ae startEnumeration];
}

@end
