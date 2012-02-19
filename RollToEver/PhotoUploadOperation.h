//
//  PhotoUploadOperation.h
//  RollToEver
//
//  Created by fifnel on 2012/02/19.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "Evernote.h"

@interface PhotoUploadOperation : NSOperation
{
@private
    ALAsset *asset_;
}

@property(retain) id delegate;
- (id)initWithAsset:(ALAsset *)asset;

@end

@interface NSObject(PhotoUploadOperationDelegate)
- (void)PhotoUploadOperationStart:(PhotoUploadOperation *)operation;
- (void)PhotoUploadOperation:(PhotoUploadOperation *)operation progress:(NSInteger)progress max:(NSInteger)max;
- (void)PhotoUploadOperationFinish:(PhotoUploadOperation *)operation;
@end
