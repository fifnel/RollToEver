//
//  UploadedURLModel.h
//  RollToEver
//
//  Created by fifnel on 2012/02/10.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadedURLModel : NSObject

// CoreDataからすべてのURLを読み込む
+ (NSArray *)loadAllUploadedURL;

// CoreDataから任意のURLを読み込む
+ (id)loadUploadedURL:(NSString *)url;

// URLがアップロード済みかどうか
+ (BOOL)isUploadedURL:(NSString *)url;

// アップロード済みURLの保存
+ (BOOL)saveUploadedURL:(NSString *)url;

// 複数のアップロード済みURLの保存
+ (BOOL)saveUploadedURLList:(NSArray *)urlList;

// アップロード済みURLの削除
+ (void)deleteUploadedURL:(NSString *)url;

// 保存されているすべてのアップロード済みURLを削除する
+ (void)deleteAllUploadedURL;

@end
