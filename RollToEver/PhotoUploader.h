//
//  Uploader.h
//  RollToEver
//
//  Created by fifnel on 2012/02/13.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssetsEnumerator.h"
#import "AssetURLStorage.h"

@interface PhotoUploader : NSObject
{
@private
    AssetsEnumerator *enumerator_;
    NSMutableArray *urls_;
    AssetURLStorage *assetUrlStorage_;
    
    NSInteger uploadPhotosNum_;
    NSInteger uploadedPhotosNum_;
    
    BOOL working_;
}

- (void)start;

@property (assign) id delegate;

@end

@interface NSObject(PhotoUploaderDelegate)

- (void)PhotoUploaderReady:(NSInteger)totalCount cancel:(BOOL *)cancel;
- (void)PhotoUploaderUploadBegin:(ALAsset *)asset count:(NSInteger)count totalCount:(NSInteger)totalCount;
- (void)PhotoUploaderUploadEnd:(ALAsset *)asset count:(NSInteger)count totalCount:(NSInteger)totalCount;
- (void)PhotoUploaderSucceeded;
- (void)PhotoUploaderCenceled;
- (void)PhotoUploaderFailure;

@end

