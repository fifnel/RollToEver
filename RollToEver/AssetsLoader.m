//
//  AssetsLoader.m
//  RollToEver
//
//  Created by fifnel on 2012/02/18.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "AssetsLoader.h"
#import "AssetURLStorage.h"

@implementation AssetsLoader

@synthesize assetsLibrary = assetsLibrary_;

- (id)init {
    self = [super init];
    if (self != nil) {
        assetsLibrary_ = [[ALAssetsLibrary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    [assetsLibrary_ dealloc];
}

// アセットURLのリストを取得する
- (NSMutableArray *)EnumerateURLExcludeDuplication:(BOOL)exclude {
    __block NSMutableArray *result = [[[[NSMutableArray alloc] init] autorelease] retain];
    __block BOOL completed = NO;
    __block AssetURLStorage *urlStorage = nil;

    if (exclude) {
        urlStorage = [[[AssetURLStorage alloc] init] autorelease];
    }
    
    // グループ内画像1枚ずつ呼び出される
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock =
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
    ALAssetsLibraryGroupsEnumerationResultsBlock usingBlock =
    ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        } else {
            completed = YES;
        }
    };
    
    // 列挙に失敗したときに呼び出される
    ALAssetsLibraryAccessFailureBlock failureBlock = 
    ^(NSError *error) {
        NSLog(@"error:%@", error);
        completed = YES;
    };
    
    // 列挙開始
    [assetsLibrary_ enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:usingBlock
                                failureBlock:failureBlock];
    
    while (!completed) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return result;
}

// 1アセットの読み込み
- (ALAsset *)loadAssetURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    return [self loadAssetURL:url];
}

// 1アセットの読み込み
- (ALAsset *)loadAssetURL:(NSURL *)url {
    __block ALAsset *result = nil;
    __block BOOL completed = NO;
    
    [assetsLibrary_ assetForURL:url
                    resultBlock:^(ALAsset *asset) {
                        result = [asset retain];
                        completed = YES;
                    }
                   failureBlock:^(NSError *error) {
                        NSLog(@"error:%@", error);
                        completed = YES;
                   }];
    
    while (!completed) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return result;
}

@end
