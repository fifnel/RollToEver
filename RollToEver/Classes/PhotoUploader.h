//
//  PhotoUploader.h
//  RollToEver
//
//  Created by fifnel on 2012/02/13.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "UploadedURLModel.h"
#import "ApplicationError.h"

/**
*  写真アップローダー.
* NSOperationを使った非同期処理
*/
@interface PhotoUploader : NSOperation

- (id)initWithDelegate:(id)delegate;

@end

/**
* 写真アップローダーのdelegate.
*/
@interface NSObject (PhotoUploaderDelegate)

/// アップロードループの開始
- (void)PhotoUploaderWillStart:(PhotoUploader *)photoUploader totalCount:(NSNumber *)totalCount;

/// アップロードの開始
- (void)PhotoUploaderWillUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount;

/// アップロード中
- (void)PhotoUploaderUploading:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount uploadedSize:(NSNumber *)uploadedSize totalSize:(NSNumber *)totalSize;

/// アップロード終了
- (void)PhotoUploaderDidUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount;

/// アップロードスキップ
- (void)PhotoUploaderDidSkipped:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount reasonException:(NSException *)exception;

/// アップロードループ終了
- (void)PhotoUploaderDidFinish:(PhotoUploader *)photoUploader;

/// エラー終了
- (void)PhotoUploaderError:(PhotoUploader *)photoUploader error:(ApplicationError *)error;

/// キャンセルされた
- (void)PhotoUploaderCanceled:(PhotoUploader *)photoUploader;

@end

