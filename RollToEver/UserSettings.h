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

@property (assign) NSString *evernoteUserId;
@property (assign) NSString *evernotePassword;
@property (assign) NSString *evernoteNotebookGUID;
@property (assign) NSString *lastPhotoDate;

@end

