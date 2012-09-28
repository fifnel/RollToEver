//
//  UserSettings.h
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* ユーザー設定読み書き.
*/
@interface UserSettings : NSObject

/// singletonインスタンス
+ (UserSettings *)sharedInstance;

/// バージョン番号取得
- (NSString *)version;

/// バージョン番号設定
- (void)setVersion:(NSString *)version;

/// 初回起動フラグ取得
- (NSString *)isFirstTime;

/// 初回起動フラグ設定
- (void)setIsFirstTime:(NSString *)isFirstTime;

/// Evernoteノートブック名取得
- (NSString *)evernoteNotebookName;

/// Evernoteノートブック名設定
- (void)setEvernoteNotebookName:(NSString *)evernoteNotebookName;

/// EvernoteノートブックGUID取得
- (NSString *)evernoteNotebookGUID;

/// EvernoteノートブックGUID設定
- (void)setEvernoteNotebookGUID:(NSString *)evernoteNotebookGUID;

/// 写真サイズIndex取得
- (NSInteger)photoSizeIndex;

/// 写真サイズIndex設定
- (void)setPhotoSizeIndex:(NSInteger)photoSizeIndex;

/// 写真サイズ取得
- (NSInteger)photoSize;

/// 動作中スリープオプション取得
- (BOOL)killIdleSleepFlag;

/// 動作中スリープオプション設定
- (void)setKillIdleSleepFlag:(BOOL)flag;

@end

