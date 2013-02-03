//
//  ALAssetTestUtility.m
//  RollToEver
//
//  Created by fifnel on 2013/02/03.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "ALAssetTestUtility.h"

@implementation ALAssetTestUtility
{
    __strong ALAssetsLibrary *_assetsLibrary;
}

- (ALAsset *)getFirstAssertByExtension:(NSString *)ext
{
    _assetsLibrary = [[ALAssetsLibrary alloc] init];

    __block ALAsset *foundAsset = nil;
    __block BOOL completed = NO;
    __block NSError *assetError = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    // グループ内画像1枚ずつ呼び出される
    __block ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock =
    ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        if (asset && [[[rep filename] pathExtension] caseInsensitiveCompare:ext] == NSOrderedSame) {
            *stop = YES;
            completed = YES;
            foundAsset = asset;
        }
    };
    
    // グループごと呼び出される
    __block ALAssetsLibraryGroupsEnumerationResultsBlock usingBlock =
    ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        } else {
            completed = YES;
            dispatch_semaphore_signal(sema);
        }
    };
    
    // 列挙に失敗したときに呼び出される
    __block ALAssetsLibraryAccessFailureBlock failureBlock =
    ^(NSError *error) {
        NSLog(@"error:%@", error);
        assetError = error;
        completed = YES;
        dispatch_semaphore_signal(sema);
    };
    
    // 列挙開始
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:usingBlock
                                failureBlock:failureBlock];
    
    if ([NSThread isMainThread]) {
        while (!completed && !assetError) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    else {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    if (assetError) {
        foundAsset = nil;
    }
    
    return foundAsset;
}

@end
