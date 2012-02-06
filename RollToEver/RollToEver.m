//
//  RollToEver.m
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "RollToEver.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetsFilter.h>

@interface RollToEver()
- (void)startUploadAsync;
- (void)uploadPhoto:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop;
- (void)RollToEverStartUploadOnMainThread:(NSDictionary *)params;
- (void)RollToEverFinishUploadOnMainThread:(NSDictionary *)params;
- (void)RollToEverFinishAllUploadOnMainThread:(NSDictionary *)params;

@end

@implementation RollToEver

@synthesize delegate = delegate_;
@synthesize assetsLibrary = assetsLibrary_;
@synthesize lastUploadDate = lastUploadDate_;
@synthesize dateFormatter = dateFormatter_;

/**
 初期化処理
 */
- (id)init {
    self = [super init];
    if (self != nil) {
        assetsLibrary_ = [[ALAssetsLibrary alloc] init];
        
        dateFormatter_ = [[NSDateFormatter alloc]init];
        [dateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
        
        lastUploadDate_ = nil;
    }
    
    return self;
}

/**
 解放処理
 */
- (void)dealloc {
    [dateFormatter_ release];
    [assetsLibrary_ release];
    [lastUploadDate_ release];
    
    [super dealloc];
}

/**
 アップロードの開始
 */
- (void)startUpload {
    [self performSelectorInBackground:@selector(startUploadAsync) withObject:nil];
}

- (void)startUploadAsync {
    NSString *dateStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastUpload"];
    if (dateStr == nil) {
        lastUploadDate_ = nil;
    } else {
        lastUploadDate_ = [[dateFormatter_ dateFromString:dateStr]retain];
    }
    NSLog(@"last upload=%@", lastUploadDate_);
    
    
    // グループ内画像1枚ずつ呼び出される
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock =
    ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self uploadPhoto:result index:index stop:stop];
        }
    };
    
    // グループごと呼び出される
    ALAssetsLibraryGroupsEnumerationResultsBlock usingBlock =
    ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSNumber *num = [[NSNumber alloc]initWithInteger:[group numberOfAssets]];
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    num, @"num",
                                    nil];
            [self performSelectorOnMainThread:@selector(RollToEverStartUploadOnMainThread:) withObject:params waitUntilDone:YES];
            NSLog(@"upload start numberOfAssets:%d", [group numberOfAssets]);
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
        } else {
            NSLog(@"upload finish");
            [self performSelectorOnMainThread:@selector(RollToEverFinishAllUploadOnMainThread:) withObject:nil waitUntilDone:YES];
        }
    };
    
    // 列挙開始
    [assetsLibrary_ enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                  usingBlock:usingBlock
                                failureBlock:^(NSError *error) {
                                    NSLog(@"failure");
                                }];
}

/**
 写真1枚のアップロード
 */
- (void)uploadPhoto:(ALAsset *)asset index:(NSInteger)index stop:(BOOL *)stop {
    /*
    NSLog(@"index=%d date=%@ type=%@ url=%@",
          index,
          [asset valueForProperty:ALAssetPropertyDate],
          [asset valueForProperty:ALAssetPropertyType],
          [asset valueForProperty:ALAssetPropertyURLs]
          );
     */
    NSDate *photoDate = [asset valueForProperty:ALAssetPropertyDate];
    if (photoDate == nil) {
        return;
    }
    if (lastUploadDate_ != nil && [photoDate earlierDate:lastUploadDate_] == photoDate) {
//        return; // test
    }
    
    // ここでアップロード処理を入れる
    sleep(2); // dummy
    
    // 最終アップロード日時の更新
    lastUploadDate_ = photoDate;
    NSString *dateStr = [dateFormatter_ stringFromDate:lastUploadDate_];
    [[NSUserDefaults standardUserDefaults] setValue:dateStr forKey:@"LastUpload"];
    
    NSNumber *indexNumber = [[NSNumber alloc]initWithInteger:index];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            asset, @"asset",
                            indexNumber, @"index",
                            nil];
    [self performSelectorOnMainThread:@selector(RollToEverFinishUploadOnMainThread:) withObject:params waitUntilDone:YES];
}

/**
 アップロード開始（メインスレッドから呼ばれる）
 */
- (void)RollToEverStartUploadOnMainThread:(NSDictionary *)params {
    NSNumber *num = [params objectForKey:@"num"];
    [delegate_ RollToEverStartUpload:[num integerValue]];
}

/**
 1枚の画像アップロード完了（メインスレッドから呼ばれる）
 */
- (void)RollToEverFinishUploadOnMainThread:(NSDictionary *)params {
    ALAsset *asset = [params objectForKey:@"asset"];
    NSNumber *index = [params objectForKey:@"index"];
    [delegate_ RollToEverFinishUpload:asset index:[index integerValue]];
}

/**
 全部の画像アップロード完了（メインスレッドから呼ばれる）
 */
- (void)RollToEverFinishAllUploadOnMainThread:(NSDictionary *)params {
    [delegate_ RollToEverFinishAllUpload];
}

@end
