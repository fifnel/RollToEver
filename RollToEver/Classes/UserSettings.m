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

@implementation UserSettings

SINGLETON_GCD(UserSettings);

#pragma  mark - propertyes methods

static NSString *VERSION = @"Version";
- (NSString *)version
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:VERSION];
}

- (void)setVersion:(NSString *)version
{
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:VERSION];
}

static NSString *ISFIRSTTIME = @"IsFirstTime";
- (NSString *)isFirstTime
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:ISFIRSTTIME];
}

- (void)setIsFirstTime:(NSString *)isFirstTime
{
    [[NSUserDefaults standardUserDefaults] setValue:isFirstTime forKey:ISFIRSTTIME];
}

static NSString *EVERNOTE_USER_ID = @"EvernoteUserID";
- (NSString *)evernoteUserId
{
    NSString *ret = [[PDKeychainBindings sharedKeychainBindings] stringForKey:EVERNOTE_USER_ID];
    if (ret != nil) {
        return [NSString stringWithString:ret];
    }
    return nil;
}

- (void)setEvernoteUserId:(NSString *)evernoteUserId
{
    [[PDKeychainBindings sharedKeychainBindings] setString:evernoteUserId forKey:EVERNOTE_USER_ID];
}

static NSString *EVERNOTE_PASSWORD = @"EvernotePassword";
- (NSString *)evernotePassword
{
    NSString *ret = [[PDKeychainBindings sharedKeychainBindings] stringForKey:EVERNOTE_PASSWORD];
    if (ret != nil) {
        return [NSString stringWithString:ret];
    }
    return nil;
}

- (void)setEvernotePassword:(NSString *)evernotePassword {
    [[PDKeychainBindings sharedKeychainBindings] setString:evernotePassword forKey:EVERNOTE_PASSWORD];
}

static NSString *EVERNOTE_NOTEBOOK_NAME = @"EvernoteNotebookName";
- (NSString *)evernoteNotebookName
{
    NSString *ret = [[PDKeychainBindings sharedKeychainBindings] stringForKey:EVERNOTE_NOTEBOOK_NAME];
    if (ret != nil) {
        return [NSString stringWithString:ret];
    }
    return nil;
}

- (void)setEvernoteNotebookName:(NSString *)evernoteNotebookName
{
    [[PDKeychainBindings sharedKeychainBindings] setString:evernoteNotebookName forKey:EVERNOTE_NOTEBOOK_NAME];
}

static NSString *EVERNOTE_NOTEBOOK_GUID = @"EvernoteNotebookGUID";
- (NSString *)evernoteNotebookGUID
{
    NSString *ret = [[PDKeychainBindings sharedKeychainBindings] stringForKey:EVERNOTE_NOTEBOOK_GUID];
    if (ret != nil) {
        return [NSString stringWithString:ret];
    }
    return nil;
}

- (void)setEvernoteNotebookGUID:(NSString *)evernoteNotebookGUID
{
    [[PDKeychainBindings sharedKeychainBindings] setString:evernoteNotebookGUID forKey:EVERNOTE_NOTEBOOK_GUID];
}

static NSString *PHOTO_SIZE_INDEX = @"PHOTO_SIZE_INDEX";
// サイズはiPhoneのメールに画像を添付した場合に選べるオリジナル・大・中・小を参考にした
static const NSInteger photoSize_[] = {0, 1224*1632, 480*640, 240*320};
- (NSInteger)photoSizeIndex
{
    return [[[NSUserDefaults standardUserDefaults] stringForKey:PHOTO_SIZE_INDEX] integerValue];
}

- (void)setPhotoSizeIndex:(NSInteger)photoSizeIndex
{
    NSString *str = [NSString stringWithFormat:@"%d", photoSizeIndex];
    [[NSUserDefaults standardUserDefaults] setValue:str forKey:PHOTO_SIZE_INDEX];
}

- (NSInteger)photoSize
{
    NSInteger index = [self photoSizeIndex];
    if (index < 0 || index >= sizeof(photoSize_)/sizeof(NSInteger)) {
        return 0;
    } else {
        return photoSize_[index];
    }
}

@end
