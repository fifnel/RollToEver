//
//  UserSettings.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "UserSettings.h"
#import "PDKeychainBindings.h"
#import "GCDSingleton.h"

/**
* ユーザー設定読み書き.
*/
@implementation UserSettings

/// Singleton
SINGLETON_GCD(UserSettings);

#pragma  mark - properties methods

/// バージョン番号のキー
static NSString *VERSION = @"Version";

/// バージョン番号の取得
- (NSString *)version {
    return [[NSUserDefaults standardUserDefaults] stringForKey:VERSION];
}

/// バージョン番号の設定
- (void)setVersion:(NSString *)version {
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:VERSION];
}

/// 初回起動フラグのキー
static NSString *ISFIRSTTIME = @"IsFirstTime";

/// 初回起動フラグの取得
- (NSString *)isFirstTime {
    return [[NSUserDefaults standardUserDefaults] stringForKey:ISFIRSTTIME];
}

/// 初回起動フラグの設定
- (void)setIsFirstTime:(NSString *)isFirstTime {
    [[NSUserDefaults standardUserDefaults] setValue:isFirstTime forKey:ISFIRSTTIME];
}

/// EvernoteユーザーIDのキー
static NSString *EVERNOTE_USER_ID = @"EvernoteUserID";

/// EvernoteユーザーID取得
- (NSString *)evernoteUserId {
    NSString *ret = [[PDKeychainBindings sharedKeychainBindings] stringForKey:EVERNOTE_USER_ID];
    if (ret != nil) {
        return [NSString stringWithString:ret];
    }
    return nil;
}

/// EvernoteユーザーID設定
- (void)setEvernoteUserId:(NSString *)evernoteUserId {
    [[PDKeychainBindings sharedKeychainBindings] setString:evernoteUserId forKey:EVERNOTE_USER_ID];
}

/// Evernotパスワードのキー
static NSString *EVERNOTE_PASSWORD = @"EvernotePassword";

/// Evernoteパスワード取得
- (NSString *)evernotePassword {
    NSString *ret = [[PDKeychainBindings sharedKeychainBindings] stringForKey:EVERNOTE_PASSWORD];
    if (ret != nil) {
        return [NSString stringWithString:ret];
    }
    return nil;
}

/// Evernoteパスワード設定
- (void)setEvernotePassword:(NSString *)evernotePassword {
    [[PDKeychainBindings sharedKeychainBindings] setString:evernotePassword forKey:EVERNOTE_PASSWORD];
}

/// Evernoteノートブック名のキー
static NSString *EVERNOTE_NOTEBOOK_NAME = @"EvernoteNotebookName";

/// Evernoteノートブック名取得
- (NSString *)evernoteNotebookName {
    NSString *ret = [[PDKeychainBindings sharedKeychainBindings] stringForKey:EVERNOTE_NOTEBOOK_NAME];
    if (ret != nil) {
        return [NSString stringWithString:ret];
    }
    return nil;
}

/// Evernoteノートブック名設定
- (void)setEvernoteNotebookName:(NSString *)evernoteNotebookName {
    [[PDKeychainBindings sharedKeychainBindings] setString:evernoteNotebookName forKey:EVERNOTE_NOTEBOOK_NAME];
}

/// EvernoteノートブックGUIDのキー
static NSString *EVERNOTE_NOTEBOOK_GUID = @"EvernoteNotebookGUID";

/// EvernoteノートブックGUID取得
- (NSString *)evernoteNotebookGUID {
    NSString *ret = [[PDKeychainBindings sharedKeychainBindings] stringForKey:EVERNOTE_NOTEBOOK_GUID];
    if (ret != nil) {
        return [NSString stringWithString:ret];
    }
    return nil;
}

/// EvernoteノートブックGUID設定
- (void)setEvernoteNotebookGUID:(NSString *)evernoteNotebookGUID {
    [[PDKeychainBindings sharedKeychainBindings] setString:evernoteNotebookGUID forKey:EVERNOTE_NOTEBOOK_GUID];
}

/// 写真サイズIndexのキー
static NSString *PHOTO_SIZE_INDEX = @"PHOTO_SIZE_INDEX";
/// 写真サイズのテーブル
/// サイズはiPhoneのメールに画像を添付した場合に選べるオリジナル・大・中・小を参考にした
static const NSInteger photoSize_[] = {0, 1224 * 1632, 480 * 640, 240 * 320};

/// 写真サイズIndex取得
- (NSInteger)photoSizeIndex {
    return [[[NSUserDefaults standardUserDefaults] stringForKey:PHOTO_SIZE_INDEX] integerValue];
}

/// 写真サイズIndex設定
- (void)setPhotoSizeIndex:(NSInteger)photoSizeIndex {
    NSString *str = [NSString stringWithFormat:@"%d", photoSizeIndex];
    [[NSUserDefaults standardUserDefaults] setValue:str forKey:PHOTO_SIZE_INDEX];
}

/// 写真サイズ取得
- (NSInteger)photoSize {
    NSInteger index = [self photoSizeIndex];
    if (index < 0 || index >= sizeof(photoSize_) / sizeof(NSInteger)) {
        return 0;
    } else {
        return photoSize_[index];
    }
}

@end
