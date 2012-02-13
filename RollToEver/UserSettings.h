//
//  UserSettings.h
//  RollToEver
//
//  Created by fifnel on 2012/02/08.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject

+(UserSettings *)sharedInstance;

- (NSString *)evernoteUserId;
- (void)setEvernoteUserId:(NSString *)evernoteUserId;

- (NSString *)evernotePassword;
- (void)setEvernotePassword:(NSString *)evernotePassword;

- (NSString *)evernoteNotebookName;
- (void)setEvernoteNotebookName:(NSString *)evernoteNotebookName;

- (NSString *)evernoteNotebookGUID;
- (void)setEvernoteNotebookGUID:(NSString *)evernoteNotebookGUID;

@end

