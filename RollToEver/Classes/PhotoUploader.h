//
//  Uploader.h
//  RollToEver
//
//  Created by fifnel on 2012/02/13.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "AssetURLStorage.h"

@interface PhotoUploader : NSOperation
{
@private
    ALAssetsLibrary *assetsLibrary_;
    AssetURLStorage *assetUrlStorage_;
}

- (id)initWithDelegate:(id)delegate;

@property (assign) id delegate;
@property (readonly) NSInteger currentIndex;
@property (readonly) NSInteger totalCount;

@end

@interface NSObject(PhotoUploaderDelegate)

- (void)PhotoUploaderWillStart:(PhotoUploader *)photoUploader totalCount:(NSNumber *)totalCount;
- (void)PhotoUploaderWillUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount;
- (void)PhotoUploaderUploading:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount uploadedSize:(NSNumber *)uploadedSize totalSize:(NSNumber *)totalSize;
- (void)PhotoUploaderDidUpload:(PhotoUploader *)photoUploader asset:(ALAsset *)asset index:(NSNumber *)index totalCount:(NSNumber *)totalCount;
- (void)PhotoUploaderDidFinish:(PhotoUploader *)photoUploader;
- (void)PhotoUploaderError:(PhotoUploader *)photoUploader error:(NSError *)error;

@end

