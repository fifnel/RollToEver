//
//  PhotoUploader.m
//  RollToEver
//
//  Created by fifnel on 2012/02/13.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "Config.h"

#import "PhotoUploader.h"
#import "UserSettings.h"
#import "ALAssetsLibrary+BlockingUtility.h"
#import "ALAssetsLibrary+FilteredList.h"
#import "NSObject+InvocationUtils.h"
#import "THTTPAsyncClient.h"
#import "EvernoteSDK.h"
#import "EvernoteSession+ProgressableClient.h"
#import "ALAsset+TransformForEvernote.h"
#import "EDAMNote+CreateFromALAsset.h"
#import "UnsupportedFormatException.h"

/**
* 写真アップローダーdelegate.
* delegateをメインスレッドから呼び出すために呼び出される踏み台となるdelegate
*/
@interface PhotoUploader ()

/// アップロードループの開始
- (void)PhotoUploaderWillStartAsync:(PhotoUploader *)photoUploader
                         totalCount:(NSNumber *)totalCount;

/// アップロードの開始
- (void)PhotoUploaderWillUploadAsync:(PhotoUploader *)photoUploader
                               asset:(ALAsset *)asset
                               index:(NSNumber *)index
                          totalCount:(NSNumber *)totalCount;

/// アップロード終了
- (void)PhotoUploaderDidUploadAsync:(PhotoUploader *)photoUploader
                              asset:(ALAsset *)asset
                              index:(NSNumber *)index
                         totalCount:(NSNumber *)totalCount;

/// アップロードループ終了
- (void)PhotoUploaderDidFinishAsync:(PhotoUploader *)photoUploader;

/// エラー処理
- (void)PhotoUploaderErrorAsync:(PhotoUploader *)photoUploader
                          error:(ApplicationError *)error;

@end

/**
*  写真アップローダー.
* NSOperationを使った非同期処理
*/
@implementation PhotoUploader {

    // デリゲート
    __weak   id _delegate;

    // アップロード済みアセットURL記録クラス
    __strong UploadedURLModel *_assetUrlStorage;

    /// アセットライブラリ
    __strong ALAssetsLibrary *_assetsLibrary;

    /// 現在処理中のアセット
    __strong ALAsset *_currentAsset;

    /// 現在処理中インデックス
    NSInteger _currentIndex;

    /// アップロードする合計数
    NSInteger _totalCount;
}

/// 初期化
- (id)init {
    self = [self initWithDelegate:nil];
    return self;
}

/// デリゲート指定付き初期化
- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self != nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        _assetUrlStorage = [[UploadedURLModel alloc] init];
        _delegate = delegate;
    }
    return self;
}

/// 非同期メイン処理
- (void)main {
    __block UploadedURLModel *urlStorage = nil;

    urlStorage = [[UploadedURLModel alloc] init];
    _currentIndex = 0;
    _currentAsset = nil;
    _totalCount = 0;

    EDAMNoteStoreClient *noteStoreClient = [[EvernoteSession sharedSession] noteStoreWithDelegate:self];

    @try {
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        NSArray *filteredAssetURLList = [assetsLibrary filteredAssetsURLList];
        if (filteredAssetURLList == nil) {
            [self PhotoUploaderErrorAsync:self error:nil];
            return;
        }
        _totalCount = [filteredAssetURLList count];
        [self PhotoUploaderWillStartAsync:self totalCount:[NSNumber numberWithInt:_totalCount]];

        NSString *notebookGUID = [UserSettings sharedInstance].evernoteNotebookGUID;
        NSInteger photoSize = [UserSettings sharedInstance].photoSize;

        for (NSInteger i = 0; i < _totalCount; i++) {
            @autoreleasepool {
                NSString *url = [filteredAssetURLList objectAtIndex:i];
                ALAsset *asset = [assetsLibrary loadAssetFromURLString:url];
                if (asset == nil) {
                    [self PhotoUploaderErrorAsync:self error:nil];
                    continue;
                }
                _currentIndex = i;
                _currentAsset = asset;

                @try {
                    [self PhotoUploaderWillUploadAsync:self
                                                 asset:asset
                                                 index:[NSNumber numberWithInt:i]
                                            totalCount:[NSNumber numberWithInt:_totalCount]];
                    EDAMNote *note = [EDAMNote createFromALAsset:asset notebook:notebookGUID photoSize:photoSize];
                    [noteStoreClient createNote:[[EvernoteSession sharedSession] authenticationToken] :note];
                    if ([self isCancelled]) {
                        [self PhotoUploaderCancelAsync:self];
                        return;
                    }
                    [urlStorage saveUploadedURL:url];
                }
                @catch (UnsupportedFormatException *exception) {
                    NSLog(@"UnsupportedFormatException:%@", [exception reason]);
                    [self PhotoUploaderDidSkipped:self
                                            asset:asset
                                            index:[NSNumber numberWithInt:i]
                                       totalCount:[NSNumber numberWithInt:_totalCount]
                                  reasonException:exception];
                    continue;
                }

                [self PhotoUploaderDidUploadAsync:self
                                            asset:asset
                                            index:[NSNumber numberWithInt:i]
                                       totalCount:[NSNumber numberWithInt:_totalCount]];
            }
        }
        _currentAsset = nil;
        [self PhotoUploaderDidFinishAsync:self];
    }
    @catch (EDAMUserException *exception) {
        NSLog(@"PhotoUploader EDAMUser exception:%@", [exception reason]);
        if ([self isCancelled]) {
            [self PhotoUploaderCancelAsync:self];
        } else {
            ApplicationError *error = [[ApplicationError alloc] initWithErrorCode:ERROR_EVERNOTE Param:[exception errorCode]];
            [self PhotoUploaderErrorAsync:self error:error];
            _currentAsset = nil;
        }
        return;
    }
    @catch (NSException *exception) {
        NSLog(@"PhotoUploader exception:%@", [exception reason]);
        if ([self isCancelled]) {
            [self PhotoUploaderCancelAsync:self];
        } else {
            ApplicationError *error = [[ApplicationError alloc] initWithErrorCode:ERROR_TRANSPORT Param:0];
            [self PhotoUploaderErrorAsync:self error:error];
            _currentAsset = nil;
        }
        return;
    }
}

#pragma mark - delegate call

/// アップロードループ開始
- (void)PhotoUploaderWillStartAsync:(PhotoUploader *)photoUploader totalCount:(NSNumber *)totalCount {
    if ([_delegate respondsToSelector:@selector(PhotoUploaderWillStart:totalCount:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderWillStart:totalCount:) withObjects:photoUploader, totalCount, nil];
    }
}

/// アップロード開始
- (void)PhotoUploaderWillUploadAsync:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount {
    if ([_delegate respondsToSelector:@selector(PhotoUploaderWillUpload:asset:index:totalCount:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderWillUpload:asset:index:totalCount:) withObjects:photoUploader, asset, index, totalCount, nil];
    }
}

/// アップロード終了
- (void)PhotoUploaderDidUploadAsync:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount {
    if ([_delegate respondsToSelector:@selector(PhotoUploaderDidUpload:asset:index:totalCount:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderDidUpload:asset:index:totalCount:) withObjects:photoUploader, asset, index, totalCount, nil];
    }

}

/// アップロードスキップ
- (void)PhotoUploaderDidSkipped:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount reasonException:(NSException *)exception {
    if ([_delegate respondsToSelector:@selector(PhotoUploaderDidSkipped:asset:index:totalCount:reasonException:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderDidSkipped:asset:index:totalCount:reasonException:) withObjects:photoUploader, asset, index, totalCount, exception, nil];
    }
}

/// アップロードループ終了
- (void)PhotoUploaderDidFinishAsync:(PhotoUploader *)photoUploader {
    if ([_delegate respondsToSelector:@selector(PhotoUploaderDidFinish:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderDidFinish:) withObjects:photoUploader, nil];
    }

}

/// エラー処理
- (void)PhotoUploaderErrorAsync:(PhotoUploader *)photoUploader error:(ApplicationError *)error; {
    if ([_delegate respondsToSelector:@selector(PhotoUploaderError:error:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderError:error:) withObjects:photoUploader, error, nil];
    }
}

/// キャンセル処理
- (void)PhotoUploaderCancelAsync:(PhotoUploader *)photoUploader {
    if ([_delegate respondsToSelector:@selector(PhotoUploaderCanceled:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderCanceled:) withObject:photoUploader waitUntilDone:NO];
    }
}

#pragma mark - THTTPAsyncClient delegate

/// 送信終了
- (void)connection:(NSURLConnection *)connection
            client:(THTTPAsyncClient *)client
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // キャンセルチェック
    if ([self isCancelled]) {
        [client cancel];
        // delegate呼び出しは処理ループ側でやっている
        return;
    }

    if ([_delegate respondsToSelector:@selector(PhotoUploaderUploading:asset:index:totalCount:uploadedSize:totalSize:)]) {
        [_delegate performSelectorOnMainThread:@selector(PhotoUploaderUploading:asset:index:totalCount:uploadedSize:totalSize:)
                                   withObjects:self,
         _currentAsset,
         [NSNumber numberWithInt:_currentIndex],
         [NSNumber numberWithInt:_totalCount],
         [NSNumber numberWithInt:totalBytesWritten],
         [NSNumber numberWithInt:totalBytesExpectedToWrite],
         nil];
    }
}

@end

