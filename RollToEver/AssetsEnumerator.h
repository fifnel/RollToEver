//
//  AssetsEnumerator.h
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/ALAssetsLibrary.h>

@interface AssetsEnumerator : NSObject

@property (retain) ALAssetsLibrary *assetsLibrary;
@property (retain) id delegate;

- (void) startEnumeration;

@end


@interface NSObject(AssetsEnumeratorDelegate)

- (void)AssetsEnumerationStart:(NSInteger)count;
- (void)AssetsEnumerationEnd;
- (void)AssetsEnumerationFind:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop;
- (void)AssetsEnumerationFailure:(NSError *)error;

@end