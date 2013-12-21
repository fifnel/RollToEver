//
//  ALAssetsLibrary+BlockingUtility.m
//  RollToEver
//
//  Created by fifnel on 2013/02/06.
//  Copyright (c) 2013年 fifnel. All rights reserved.
//

#import "ALAssetsLibrary+BlockingUtility.h"

@implementation ALAssetsLibrary (BlockingUtility)

- (NSArray *)assetsURLList
{
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    __block BOOL completed = NO;
    __block NSError *assetError = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    // グループ内画像1枚ずつ呼び出される
    __block ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock =
            ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if (asset) {
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    NSString *url = [rep.url absoluteString];
                    [result addObject:url];
                }
            };
    
    // グループごと呼び出される
    __block ALAssetsLibraryGroupsEnumerationResultsBlock usingBlock =
            ^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                    // TODO: グループのフィルタを入れたい
                    [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
                } else {
                    completed = YES;
                    dispatch_semaphore_signal(semaphore);
                }
            };

    // 列挙に失敗したときに呼び出される
    __block ALAssetsLibraryAccessFailureBlock failureBlock =
            ^(NSError *error) {
                NSLog(@"error:%@", error);
                assetError = error;
                completed = YES;
                dispatch_semaphore_signal(semaphore);
            };

    // 列挙開始
    [self enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                        usingBlock:usingBlock
                      failureBlock:failureBlock];

    // 終了待ち
    if ([NSThread isMainThread]) {
        while (!completed && !assetError) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    else {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    if (assetError) {
        result = nil;
    }

    return result;
}

- (ALAsset *)loadAssetFromURLString:(NSString *)urlString;
{
    NSURL *url = [NSURL URLWithString:urlString];
    return [self loadAssetFromURL:url];
}

// 1アセットの読み込み
- (ALAsset *)loadAssetFromURL:(NSURL *)url;
{
    /*
     cocoa touch - Error trying to assigning __block ALAsset from inside assetForURL:resultBlock: - Stack Overflow
     http://stackoverflow.com/questions/7625402/error-trying-to-assigning-block-alasset-from-inside-assetforurlresultblock
     */

    __block ALAsset *result = nil;
    __block NSError *assetError = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self assetForURL:url
        resultBlock:^(ALAsset *asset) {
            result = asset;
            dispatch_semaphore_signal(semaphore);
        }
        failureBlock:^(NSError *error) {
            assetError = error;
            dispatch_semaphore_signal(semaphore);
        }];

    if ([NSThread isMainThread]) {
        while (!result && !assetError) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    else {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }

    return result;
}

@end

