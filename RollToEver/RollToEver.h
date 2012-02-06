//
//  RollToEver.h
//  RollToEver
//
//  Created by fifnel on 2012/02/06.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

/**
 カメラロールからEvernoteへアップロードするクラス
 */
@interface RollToEver : NSObject {

@private
    id delegate_;
    ALAssetsLibrary *assetsLibrary_;
    NSDate *lastUploadDate_;
    NSDateFormatter *dateFormatter_;
}

@property (assign) id delegate;
@property (retain) ALAssetsLibrary *assetsLibrary;
@property (retain) NSDate *lastUploadDate;
@property (retain) NSDateFormatter *dateFormatter;

- (void)startUpload;

@end

/**
 各イベント通知用非形式プロトコル
 */
@interface NSObject (RollToEverDelegate)
- (void)RollToEverStartUpload:(NSInteger)num;
- (void)RollToEverFinishUpload:(ALAsset *)assert index:(NSInteger)index;
- (void)RollToEverFinishAllUpload;
@end
