//
//  AssetsLoader.m
//  RollToEver
//
//  Created by fifnel on 2012/02/18.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AssetsLoader.h"
#import "AssetURLStorage.h"

@implementation AssetsLoader {
    __strong ALAssetsLibrary *_assetsLibrary;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }

    return self;
}

// アセットURLのリストを取得する
- (NSArray *)EnumerateURLExcludeDuplication:(BOOL)exclude
{
    __block NSMutableArray *result = [[NSMutableArray alloc] init];
    __block BOOL completed = NO;
    __block NSError *assetError = nil;
    __block AssetURLStorage *urlStorage = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    if (exclude) {
        urlStorage = [[AssetURLStorage alloc] init];
    }

    // グループ内画像1枚ずつ呼び出される
    __block ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock =
            ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if (asset) {
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    NSString *url = [rep.url absoluteString];
                    if (exclude) {
                        if (![urlStorage isExistURL:url]) {
                            [result addObject:url];
                        }
                    } else {
                        [result addObject:url];
                    }
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
        result = nil;
    }

    return result;
}

// 1アセットの読み込み
- (ALAsset *)loadAssetURLString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    return [self loadAssetURL:url];
}

// 1アセットの読み込み
- (ALAsset *)loadAssetURL:(NSURL *)url
{
    /*
     cocoa touch - Error trying to assigning __block ALAsset from inside assetForURL:resultBlock: - Stack Overflow
     http://stackoverflow.com/questions/7625402/error-trying-to-assigning-block-alasset-from-inside-assetforurlresultblock
     */
    __block ALAsset *result = nil;
    __block NSError *assetError = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [_assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        result = asset;
        dispatch_semaphore_signal(sema);
    }              failureBlock:^(NSError *error) {
        assetError = error;
        dispatch_semaphore_signal(sema);
    }];

    if ([NSThread isMainThread]) {
        while (!result && !assetError) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    else {
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }

    dispatch_release(sema);

    return result;
}

@end
