//
//  EvernoteSession+Login.m
//  RollToEver
//
//  Created by fifnel on 2012/09/15.
//  Copyright (c) 2012年 fifnel. All rights reserved.
//

#import "Config.h"

#import "EvernoteSession+Login.h"

@implementation EvernoteSession (Login)

+ (BOOL)loginWithViewController:(UIViewController *)viewController
{
    // TODO: 以下の1行、ここから分離したい。Config.hを分離してキレイな実装にしたい。
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST consumerKey:CONSUMER_KEY consumerSecret:CONSUMER_SECRET];

    __block BOOL isSucceeded = NO;

    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:viewController completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated) {
            NSLog(@"authentication failed.");
            if (viewController) {
                UIAlertView *alert = [
                                      [UIAlertView alloc]
                                      initWithTitle :NSLocalizedString(@"AccountSettingLoginTitle", @"Evernote Login")
                                      message :NSLocalizedString(@"AccountSettingLoginFailed", @"Login failed")
                                      delegate :nil cancelButtonTitle :@"OK"
                                      otherButtonTitles :nil];
                [alert show];
            }

        } else {
            NSLog(@"authentication succeeded.");
            isSucceeded = YES;
        }
    }];

    return isSucceeded;
}

@end
