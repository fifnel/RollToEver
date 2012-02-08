//
//  UserSettings.m
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

/*
 参考
 Cocoa Fundamentals Guide: シングルトンインスタンスの作成
 https://developer.apple.com/jp/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/chapter_3_section_10.html
 */

#import "UserSettings.h"

@interface UserSettings()
- (NSString *)evernoteUserId;
- (void)setEvernoteUserId:(NSString *)evernoteUserId;

- (NSString *)evernotePassword;
- (void)setEvernotePassword:(NSString *)evernotePassword;

- (NSString *)evernoteNotebookGUID;
- (void)setEvernoteNotebookGUID:(NSString *)evernoteNotebookGUID;

- (NSString *)lastPhotoDate;
- (void)setLastPhotoDate:(NSString *)lastPhotoDate;

@end

@implementation UserSettings


#pragma mark - Lifetime methods override for Singleton

static UserSettings *sharedUserSettingsInstance = nil;

+(UserSettings *)sharedInstance {
    @synchronized(self) {
        if (sharedUserSettingsInstance == nil) {
            [[self alloc] init]; // ここでは代入していない
        }        
    }
    return sharedUserSettingsInstance;
}

+(id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedUserSettingsInstance == nil) {
            sharedUserSettingsInstance = [super allocWithZone:zone];
            return sharedUserSettingsInstance;  // 最初の割り当てで代入し、返す
        }
    }
    return nil; // 以降の割り当てではnilを返すようにする
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // 解放できないオブジェクトであることを示す
}

- (oneway void)release {
    // 何もしない
}

- (id)autorelease {
    return self;
}

#pragma  mark - propertyes methods

static NSString *EVERNOTE_USER_ID = @"EvernoteUserID";
- (NSString *)evernoteUserId {
    return [[NSUserDefaults standardUserDefaults] stringForKey:EVERNOTE_USER_ID];
}

- (void)setEvernoteUserId:(NSString *)evernoteUserId {
    [[NSUserDefaults standardUserDefaults] setValue:evernoteUserId forKey:EVERNOTE_USER_ID];
}

static NSString *EVERNOTE_PASSWORD = @"EvernotePassword";
- (NSString *)evernotePassword {
    return [[NSUserDefaults standardUserDefaults] stringForKey:EVERNOTE_PASSWORD];
}

- (void)setEvernotePassword:(NSString *)evernotePassword {
    [[NSUserDefaults standardUserDefaults] setValue:evernotePassword forKey:EVERNOTE_PASSWORD];
}

static NSString *EVERNOTE_NOTEBOOK_GUID = @"EvernoteNotebookGUID";
- (NSString *)evernoteNotebookGUID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:EVERNOTE_NOTEBOOK_GUID];
}

- (void)setEvernoteNotebookGUID:(NSString *)evernoteNotebookGUID {
    [[NSUserDefaults standardUserDefaults] setValue:evernoteNotebookGUID forKey:EVERNOTE_NOTEBOOK_GUID];
}

static NSString *LAST_PHOTO_DATE = @"LastPhotoDate";
- (NSString *)lastPhotoDate {
    return [[NSUserDefaults standardUserDefaults] stringForKey:LAST_PHOTO_DATE];
}

- (void)setLastPhotoDate:(NSString *)lastPhotoDate {
    [[NSUserDefaults standardUserDefaults] setValue:lastPhotoDate forKey:LAST_PHOTO_DATE];
}



@end
